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
