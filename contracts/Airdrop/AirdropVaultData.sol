pragma solidity =0.5.16;

import "../modules/Managerable.sol";
import "../modules/Operator.sol";

contract AirDropVaultData is Operator {

    
    address public optionColPool;
    address public minePool;
    address public cfnxToken;
    address public fnxToken;
    address public ftpbToken;
    
    uint256 public totalWhiteListAirdrop;
    uint256 public totalWhiteListClaimed;
    uint256 public totalFreeClaimed;
    uint256 public maxWhiteListFnxAirDrop;
    uint256 public maxFreeFnxAirDrop;
    
    uint256 public claimBeginTime;
    uint256 public claimEndTime;
    uint256 public fnxPerFreeClaimUser;

    //users in white list airdrop
    mapping (address => uint256) public userWhiteList;
    //target airdrop token list address=>min balance require
    mapping (address => uint256)  public tokenWhiteList;
    //the user which is claimed already for different token
    mapping (address=>mapping(address => bool)) public freeClaimedUserList;
    
    uint256 public sushiTotalMine;
    uint256 public sushiMineStartTime;
    uint256 public sushimineInterval = 30 days;
    mapping (address => uint256) public suhiUserMineBalance;
    mapping (uint256=>mapping(address => bool)) sushiMineRecord;
    
    event AddWhiteList(address indexed claimer, uint256 indexed amount);
    event WhiteListClaim(address indexed claimer, uint256 indexed amount,uint256 indexed ftpbnum);
    event UserFreeClaim(address indexed claimer, uint256 indexed amount,uint256 indexed ftpbnum);
    
    event AddSushiList(address indexed claimer, uint256 indexed amount);
    event SushiMineClaim(address indexed claimer, uint256 indexed amount);
}