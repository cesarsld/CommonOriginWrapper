pragma solidity ^0.7.0;

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

library SafeMath {
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}

	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		// Solidity only automatically asserts when dividing by 0
		require(b > 0, errorMessage);
		uint256 c = a / b;

		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ERC20 is IERC20 {
	using SafeMath for uint256;

	string public name;
	string public symbol;
	uint8 public decimals;

	uint256 public _totalSupply;
	mapping (address => uint256) public _balanceOf;
	mapping (address => mapping (address => uint256)) public _allowance;

	constructor (string memory _name, string memory _symbol, uint8 _decimals) {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
	}

	function totalSupply() public view override returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view override returns (uint256) {
		return _balanceOf[account];
	}

	function allowance(address owner, address spender) public view override returns (uint256) {
		return _allowance[owner][spender];
	}

	function approve(address _spender, uint256 _value) public override returns (bool _success) {
		_allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	function transfer(address _to, uint256 _value) public override returns (bool _success) {
		require(_to != address(0), "ERC20 : Recipient address is null.");
		_balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
		_balanceOf[_to] = _balanceOf[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) public override returns (bool _success) {
		require(_to != address(0), "ERC20 : Recipient address is null");
		_balanceOf[_from] = _balanceOf[_from].sub(_value);
		_balanceOf[_to] = _balanceOf[_to].add(_value);
		_allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
		emit Transfer(_from, _to, _value);
		return true;
	}

	function _mint(address _to, uint256 _amount) internal {
		_totalSupply = _totalSupply.add(_amount);
		_balanceOf[_to] = _balanceOf[_to].add(_amount);
		emit Transfer(address(0), _to, _amount);
	}

	function _burn (address _account, uint256 _amount) internal {
		require(_account != address(0), "ERC20 : Burning from address 0");

		_balanceOf[_account] = _balanceOf[_account].sub(_amount, "ERC20 : burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(_amount);
		emit Transfer (_account, address(0), _amount);
	}
}

interface AxieCore{
	function getAxie(uint256 _axieId) external view returns (uint256 /* _genes */, uint256 /* _bornAt */);
}

interface AxieExtraData {
	function getExtra(uint256 _axieId) external view returns(uint256, uint256, uint256 /* breed count */, uint256);
}

contract Ownable {
	address public owner;

	constructor () {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner, "Not owner");
		_;
	}
	
	function setOwnership(address _newOwner) external onlyOwner {
		owner = _newOwner;
	}

	
}

contract Pausable is Ownable {
	bool public isPaused;
	
	constructor () {
		isPaused = false;
	}
	
	modifier notPaused() {
		require(!isPaused, "paused");
		_;
	}
	
	function pause() external onlyOwner {
		isPaused = true;
	}
	
	function unpause() external onlyOwner {
		isPaused = false;
	}
}

contract WrappedOrigin is ERC20, Pausable {
	using SafeMath for uint256;

	IERC721 public constant axieNFT = IERC721(0xF5b0A3eFB8e8E4c201e2A935F110eAaF3FFEcb8d);
	AxieCore public constant axieCore = AxieCore(0xF5b0A3eFB8e8E4c201e2A935F110eAaF3FFEcb8d);
	AxieExtraData public constant extraData = AxieExtraData(0x10e304a53351B272dC415Ad049Ad06565eBDFE34);

	uint256[] public axies;

	event AxieWrapped(uint256 axieId);
	event AxieUnwrapped(uint256 axieId);

	constructor (string memory _name, string memory _symbol, uint8 _decimals) ERC20(_name, _symbol, _decimals)
	{}

	function isContract(address _addr) internal view returns (bool){
		uint32 _size;
		assembly {
			_size := extcodesize(_addr)
		}
		return (_size > 0);
	}

	function _getRandomNumber(uint256 _range) internal view returns(uint256) {
		return uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1)))) % _range;
	}

	// beast 0000 aqua 0100 plant 0011 bug 0001 bird 0010 reptile 0101
	function isValidCommonOrigin(uint256 _tokenId) public view returns(bool) {
		(uint256 _genes,) = axieCore.getAxie(_tokenId);
		uint256 _originGene = (_genes >> 238) & 1;
		if (_originGene != 1)
			return false;
		uint256 _classGenes = (_genes >> 252);
		if (_classGenes != 0 || _classGenes != 4 || _classGenes != 3)
			return false;
		(,,uint256 _breedCount,) =extraData.getExtra(_tokenId);
		if (_breedCount > 2)
			return false;
		return !isMystic(_genes);
	}

	function isMystic(uint256 _genes) pure internal returns (bool) {
		uint256 _part;
		uint256 _mysticSelector = 0xc0000000;
		for (uint256 i = 0; i < 6 ;i ++) {
			_part = _genes & 0xffffffff;
			if (_part & _mysticSelector == _mysticSelector)
				return true;
			_genes = _genes >> 32;
		}
		return false;
	}

	function wrap(uint256[] calldata _tokenIds) public notPaused {
		for (uint256 i = 0; i < _tokenIds.length; i++) {
			require(isValidCommonOrigin(_tokenIds[i]), "WrappedOrigin : Axie is not an Origin axie.");
			axies.push(_tokenIds[i]);
			axieNFT.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
			emit AxieWrapped(_tokenIds[i]);
		}
		_mint(msg.sender, _tokenIds.length * 10**decimals);
	}

	function unwrap(uint256 _amount) public notPaused{
		require(!isContract(msg.sender), "WrappedOrigin : Address must not be a contract.");
		unwrapFor(_amount, msg.sender);
	}

	function unwrapFor(uint256 _amount, address _recipient) public notPaused{
		require(!isContract(_recipient), "WrappedOrigin : Recipient must not be a contract.");
		require(_recipient != address(0), "WrappedOrigin : Cannot send to void address.");
		_burn(msg.sender, _amount * 10**decimals);
		for (uint256 i = 0; i < _amount; i++) {
			uint256 _index = _getRandomNumber(axies.length);
			uint256 _tokenId = axies[_index];

			axies[_index] = axies[axies.length - 1];
			axies.pop();
			axieNFT.safeTransferFrom(address(this), _recipient, _tokenId);
			emit AxieUnwrapped(_tokenId);
		}
	}

	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external view returns (bytes4) {
		require(msg.sender == address(axieNFT), "Not Axie NFT");
		return WrappedOrigin.onERC721Received.selector;
	}
}