import pytest
import shutil
import os


def pytest_addoption(parser):
    parser.addoption("--config", action="store", default=None, help="Path to the config file")
    parser.addoption("--remove", action="store_true", default=False, help="Remove working directory after tests")


@pytest.fixture(scope="session")
def config_path(request):
    return request.config.getoption("--config")


@pytest.fixture
def remove_flag(request):
    return request.config.getoption("--remove")


@pytest.fixture(scope="session", autouse=True)
def cleanup():
    yield
    # This code will run after all tests are completed
    pycache_dir = os.path.join(os.path.dirname(__file__), '__pycache__')
    if os.path.exists(pycache_dir):
        shutil.rmtree(pycache_dir)


# Container flavours: the gmx steps' GMXLIB env var is built by the step tests
# from $CONDA_PREFIX (a host path) that does not exist inside the container,
# so the custom PMX force field would not be found by the containerised
# pdb2gmx / grompp. GROMACS detects <name>.ff directories in the working
# directory, and openLibraryFile() (used for residuetypes.dat and friends)
# searches the CWD first, so copy both the FF dir the topology references and
# the mutff-level GROMACS data files into the sandbox (the container CWD)
# right after staging: pdb2gmx gets its -ff lookup and residue-type DB from the
# CWD and grompp resolves the topology's #include "<ff>.ff/..." from it.
@pytest.fixture(scope="session", autouse=True)
def _pmx_container_forcefield(request):
    config = request.config.getoption("--config") or ""
    if not (("workflow.docker.yml" in config) or ("workflow.singularity.yml" in config)):
        return
    import re
    import zipfile
    from pathlib import Path

    import biobb_gromacs.gromacs.grompp as _grompp_mod
    import biobb_gromacs.gromacs.pdb2gmx as _pdb2gmx_mod

    def _ff_dirs(self):
        gmx_lib = getattr(self, "gmx_lib", None)
        if not gmx_lib:
            return []
        lib = Path(gmx_lib)
        ff = getattr(self, "force_field", None)
        if ff:
            cand = lib / f"{ff}.ff"
            return [cand] if cand.is_dir() else []
        try:
            with zipfile.ZipFile(self.input_top_zip_path) as zf:
                tops = [n for n in zf.namelist() if n.endswith(".top")]
                content = zf.read(tops[0]).decode("utf-8", "ignore") if tops else ""
            names = re.findall(r'#include\s+"([^"]+?\.ff)/', content)
            return sorted({lib / n for n in names if (lib / n).is_dir()})
        except Exception:
            return []

    def _patch(cls):
        orig_stage = cls.stage_files

        def stage_files(self, *args, **kwargs):
            orig_stage(self, *args, **kwargs)
            unique = (getattr(self, "stage_io_dict", None) or {}).get("unique_dir")
            if getattr(self, "container_path", None) and unique:
                # FF dirs: pdb2gmx -ff lookup prefers the CWD, and grompp
                # resolves the topology's #include "<ff>.ff/..." from it.
                for ff_dir in _ff_dirs(self):
                    dst = Path(unique) / ff_dir.name
                    if not dst.exists():
                        shutil.copytree(ff_dir, dst)
                # GROMACS library data files (residuetypes.dat with the hybrid
                # *2A types, atommass.dat, elements.dat, ...) live at the
                # mutff/ level, not inside the FF dir. openLibraryFile()
                # searches the CWD first, so copy them into the sandbox;
                # GMXLIB itself is a host path that does not exist inside the
                # container.
                gmx_lib = getattr(self, "gmx_lib", None)
                if gmx_lib:
                    mutff = Path(gmx_lib)
                    if mutff.is_dir():
                        for f in sorted(mutff.iterdir()):
                            if f.is_file():
                                dst = Path(unique) / f.name
                                if not dst.exists():
                                    shutil.copy2(f, dst)

        cls.stage_files = stage_files

    _patch(_pdb2gmx_mod.Pdb2gmx)
    _patch(_grompp_mod.Grompp)

    # Container flavours: Grompp.launch guards the -n flag with
    # Path(stage_io_dict["in"]["input_ndx_path"]).exists(), but in container
    # mode that entry is the container path (/data/index_pmx.ndx) while the
    # file sits in the host sandbox -> the guard fails and -n is silently
    # dropped, so grompp cannot resolve the mdp group names (FREEZE / 20).
    # Re-append -n (the bare name, the cmd cd's into /data) when the staged
    # file exists on the host.
    orig_run_biobb = _grompp_mod.Grompp.run_biobb

    def run_biobb(self):
        ndx = self.stage_io_dict["in"].get("input_ndx_path")
        if getattr(self, "container_path", None) and ndx and "-n" not in self.cmd:
            from pathlib import PurePath
            name = PurePath(ndx).name
            if (Path(self.stage_io_dict.get("unique_dir", "")) / name).exists():
                self.cmd.extend(["-n", name])
        return orig_run_biobb(self)

    _grompp_mod.Grompp.run_biobb = run_biobb
