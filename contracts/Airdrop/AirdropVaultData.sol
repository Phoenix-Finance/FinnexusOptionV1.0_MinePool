pragma solidity =0.5.16;

import "../modules/Managerable.sol";

contract AirDropVaultData is Managerable {


    address public optionColPool;
    address public minePool;
    address public fnxToken;
    address public ftpbToken;
     
    uint256 public totalAirdropFnx;
    uint256 public fnxPerPerson;
    uint256 public totalPerson;
    
    //the user's locked total balance
    mapping (address => uint256) public airDropWhiteList;
    
    /**
     * @dev Emitted when `owner` locked  `amount` FPT, which net worth is  `worth` in USD. 
     */
    event ClaimAirdrop(address indexed claimer, uint256 indexed amount,uint256 indexed ftpbnum);

}