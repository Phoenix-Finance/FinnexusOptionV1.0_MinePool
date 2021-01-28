pragma solidity =0.5.16;

import "../modules/Ownable.sol";

interface IColPool {
    function getUserTotalWorth(address _account) external view returns (uint256);
}

contract PoolAdapter is Ownable{
    
    address public optionColPool = 0x120f18F5B8EdCaA3c083F9464c57C11D81a9E549;
 
    function setColPool(address _optionColPool) public onlyOwner {
        optionColPool = _optionColPool;
    }
    
    function balanceOf(address _account) external view returns (uint256){
        return IColPool(optionColPool).getUserTotalWorth(_account);
    }
}