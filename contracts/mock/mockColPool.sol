pragma solidity 0.5.16;


import "../modules/Ownable.sol";
/**
 * @dev Example of the ERC20 Token.
 */
interface mocktoken {
   function mint(address account, uint256 amount) external;
}
 
contract mockColPool is Ownable{
      address public ftpbToken;
    function addCollateral(address collateral,uint256 amount) external payable{
        require(collateral != address(0));
        mocktoken(ftpbToken).mint(address(this),amount);
    }

    function initialize(address _ftpb)
         public
         onlyOwner
    {
        ftpbToken = _ftpb;
    }
}