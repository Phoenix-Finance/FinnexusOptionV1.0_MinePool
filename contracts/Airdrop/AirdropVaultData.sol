pragma solidity =0.5.16;

import "../modules/Managerable.sol";
import "../modules/Operator.sol";

contract AirDropVaultData is Operator {


    address public optionColPool;
    address public minePool;
    address public fnxToken;
    address public ftpbToken;
    uint256 public totalAirdrop;
    uint256 public totalClaimed;
    //the user's locked total balance
    mapping (address => uint256) public airDropWhiteList;
    
    event AddWhiteList(address indexed claimer, uint256 indexed amount);
    event ClaimAirdrop(address indexed claimer, uint256 indexed amount,uint256 indexed ftpbnum);

}