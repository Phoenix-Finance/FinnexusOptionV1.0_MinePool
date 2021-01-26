pragma solidity =0.5.16;

import "../modules/Ownable.sol";

interface IColPool {
    function userInputCollateral(address user,address collateral) external view returns (uint256);
}

contract PoolAdapter is Ownable{
    
    address public optionColPool;
    address public collateral;
    
    function setColPool(address _optionColPool,address _collateral) public onlyOwner {
        optionColPool = _optionColPool;
        collateral = _collateral;
    }
    
    function balanceOf(address _account) external view returns (uint256){
        return IColPool(optionColPool).userInputCollateral(_account,collateral);
    }
}