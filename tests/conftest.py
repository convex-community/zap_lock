import brownie
from brownie import Contract
import pytest
from brownie import accounts, ClaimLockZapLite
from .constants import CRV, CVX, CVXCRV, CRV_DEPOSIT, SUSHI_ROUTER, WETH, CVX_LOCKER, CVXCRV_REWARDS, CVX_REWARDS
from brownie import chain


@pytest.fixture(scope="session")
def zap(ClaimLockZapLite, owner):
    claim_zap = ClaimLockZapLite.deploy({'from': owner})
    claim_zap.setApprovals({'from': owner})
    yield claim_zap


@pytest.fixture(scope="session")
def crv():
    yield Contract.from_explorer(CRV)


@pytest.fixture(scope="session")
def cvx():
    yield Contract.from_explorer(CVX)


@pytest.fixture(scope="session")
def cvxcrv():
    yield Contract.from_explorer(CVXCRV)


@pytest.fixture(scope="session")
def cvxcrv_rewards():
    yield Contract.from_explorer(CVXCRV_REWARDS)


@pytest.fixture(scope="session")
def cvx_rewards():
    yield Contract.from_explorer(CVX_REWARDS)


@pytest.fixture(scope="session")
def crv_deposit():
    yield Contract.from_explorer(CRV_DEPOSIT)


@pytest.fixture(scope="session")
def cvx_locker():
    yield Contract.from_explorer(CVX_LOCKER)


@pytest.fixture(scope="session")
def sushiswap_router():
    yield Contract.from_explorer(SUSHI_ROUTER)


@pytest.fixture(scope="session")
def alice(accounts):
    yield accounts[1]


@pytest.fixture(scope="session")
def owner(accounts):
    yield accounts[0]


@pytest.fixture(scope="session", autouse=True)
def buy_tokens(alice, sushiswap_router, crv_deposit, crv, cvx, cvxcrv, cvx_rewards, cvxcrv_rewards, cvx_locker):

    def swap(token):
        sushiswap_router.swapExactETHForTokens(
            1,
            [WETH, token],
            alice,
            9999999999,
            {
                "from": alice,
                "value": "20 ether"
            }
        )

    swap(CVX)
    swap(CRV)
    crv.approve(crv_deposit, 2 ** 256 - 1, {'from': alice})
    cvx.approve(cvx_locker, 2 ** 256 - 1, {'from': alice})
    cvx.approve(cvx_rewards, 2 ** 256 - 1, {'from': alice})
    cvxcrv.approve(cvxcrv_rewards, 2 ** 256 - 1, {'from': alice})
    crv_deposit.deposit(crv.balanceOf(alice), False, {'from': alice})
    swap(CRV)
    cvx_locker.lock(alice, cvx.balanceOf(alice) // 3, 0, {'from': alice})
    cvx_rewards.stake(cvx.balanceOf(alice) // 3, {'from': alice})
    cvxcrv_rewards.stake(cvxcrv.balanceOf(alice) // 3, {'from': alice})
    chain.mine(1000)
    assert cvx_rewards.earned(alice) > 0
    assert cvxcrv_rewards.earned(alice) > 0
    _, locking_rewards = cvx_locker.claimableRewards(alice)['userRewards']
    assert locking_rewards > 0
    assert cvxcrv.balanceOf(alice) > 0
    assert cvx.balanceOf(alice) > 0
    assert crv.balanceOf(alice) > 0