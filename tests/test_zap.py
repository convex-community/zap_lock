import brownie
import pytest


def test_claim(alice, zap, cvx, crv, cvxcrv, cvx_locker, cvx_rewards, cvxcrv_rewards):

    for token in [cvx, crv, cvxcrv]:
        token.approve(zap, 2 ** 256 - 1, {'from': alice})

    original_cvxcrv_share_balance = cvxcrv_rewards.balanceOf(alice)
    original_cvx_rewards_balance = cvx_rewards.balanceOf(alice)
    original_cvx_locker_balance = cvx_locker.lockedBalances(alice)['total']

    zap.claimRewards({'from': alice})

    assert cvx.balanceOf(alice) == 0
    assert cvxcrv.balanceOf(alice) == 0
    assert cvxcrv.balanceOf(alice) == 0
    assert cvx_rewards.earned(alice) == 0
    assert cvxcrv_rewards.earned(alice) == 0
    assert cvx_locker.claimableRewards(alice)['userRewards'][1] == 0

    assert original_cvx_rewards_balance == cvx_rewards.balanceOf(alice)
    # need better testing with some kind of calculus for exact vault share amounts
    assert cvxcrv_rewards.balanceOf(alice) > original_cvxcrv_share_balance
    assert cvx_locker.lockedBalances(alice)['total'] > original_cvx_locker_balance
