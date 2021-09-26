pragma solidity ^0.6.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../interfaces/IBasicRewards.sol";
import "../interfaces/ICvxCrvDeposit.sol";
import "../interfaces/ICvxLocker.sol";
import "../interfaces/ICvxRewards.sol";

contract ClaimLockZap {
    using SafeERC20 for IERC20;

    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant cvx = address(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
    address public constant cvxCrv = address(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);
    address public constant crvDeposit = address(0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae);
    address public constant cvxCrvRewards = address(0x3Fe65692bfCD0e6CF84cB1E7d24108E434A7587e);
    address public constant cvxRewards = address(0xCF50b810E57Ac33B91dCF525C6ddd9881B139332);
    address public constant cvxLocker = address(0xD18140b4B819b895A3dba5442F959fA44994AF50);

    address public immutable owner;

    constructor() public {
        owner = msg.sender;
    }

    function setApprovals() external {
        require(msg.sender == owner, "!auth");
        IERC20(crv).safeApprove(crvDeposit, 0);
        IERC20(crv).safeApprove(crvDeposit, uint256(-1));

        IERC20(cvx).safeApprove(cvxLocker, 0);
        IERC20(cvx).safeApprove(cvxLocker, uint256(-1));

        IERC20(cvxCrv).safeApprove(cvxCrvRewards, 0);
        IERC20(cvxCrv).safeApprove(cvxCrvRewards, uint256(-1));
    }

    function claimRewards(
        address[] calldata rewardContracts,
        address[] calldata extraRewardContracts,
        bool claimStakedCvx,
        bool claimCvxCrv,
        bool claimLockedCvx
    ) external{

        //claim from main curve LP pools
        for(uint256 i = 0; i < rewardContracts.length; i++){
            if(rewardContracts[i] == address(0)) break;
            IBasicRewards(rewardContracts[i]).getReward(msg.sender,true);
        }

        for(uint256 i = 0; i < extraRewardContracts.length; i++){
            if(extraRewardContracts[i] == address(0)) break;
            IBasicRewards(extraRewardContracts[i]).getReward(msg.sender);
        }

        //claim and don't restake cvx locking rewards yet
        if (claimLockedCvx) {
            ICvxLocker(cvxLocker).getReward(msg.sender,false);
        }

        //claim and don't restake cvx staking rewards yet
        if (claimStakedCvx) {
            ICvxRewards(cvxRewards).getReward(msg.sender,true,false);
        }
        //claim from cvxCrv rewards
        if (claimCvxCrv) {
            IBasicRewards(cvxCrvRewards).getReward(msg.sender,true);
        }

        uint256 crvBalance = IERC20(crv).balanceOf(msg.sender);
        uint256 cvxBalance = IERC20(cvx).balanceOf(msg.sender);

        if(crvBalance > 0){
            //pull user crv balance
            IERC20(crv).safeTransferFrom(msg.sender, address(this), crvBalance);

            //deposit
            ICvxCrvDeposit(crvDeposit).deposit(crvBalance,false);
        }

        // get user cvxcrvamount
        uint256 cvxCrvBalance = IERC20(cvxCrv).balanceOf(msg.sender);
        if (cvxCrvBalance > 0) {
            //pull cvxcrv
            IERC20(cvxCrv).safeTransferFrom(msg.sender, address(this), cvxCrvBalance);
        }

        //get contract cvxcrvamount
        cvxCrvBalance = IERC20(cvxCrv).balanceOf(address(this));
        if (cvxCrvBalance > 0) {
            //stake for msg.sender
            IBasicRewards(cvxCrvRewards).stakeFor(msg.sender, cvxCrvBalance);
        }

        if(cvxBalance > 0){
            //pull cvx
            IERC20(cvx).safeTransferFrom(msg.sender, address(this), cvxBalance);
            //lock for msg.sender
            ICvxLocker(cvxLocker).lock(msg.sender, cvxBalance, 0);
        }
    }

}