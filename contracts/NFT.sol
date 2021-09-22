// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract HermesHeroes is ERC721, ERC721URIStorage, Pausable, Ownable {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    string private _baseURIPrefix = "https://raw.githubusercontent.com/bitdeep/nft/master/hermesdefi/";
    uint public maxTokensPerTransaction = 10;
    uint256 public tokenPrice = 150000000000000000000; //150 IRIS
    uint256 public nftsNumber = 7;
    uint256 public nftsPublicNumber = 6;
    IERC20 public token;
    Counters.Counter private _tokenIdCounter;
    address public treasure;
    constructor() ERC721("Hermes Heroes", "Hermes") {
        treasure = msg.sender;
        _tokenIdCounter.increment();
        token = IERC20( address(0xdaB35042e63E93Cc8556c9bAE482E5415B5Ac4B1) );
    }

    function setTreasure(address _addr) public onlyOwner {
        treasure = _addr;
    }

    function setToken(address _addr) public onlyOwner {
        token = IERC20(_addr);
    }

    function setMaxTokensPerTransaction(uint _value) public onlyOwner {
        maxTokensPerTransaction = _value;
    }

    function setTokenPrice(uint256 _value) public onlyOwner {
        tokenPrice = _value;
    }

    function setNftsNumber(uint256 _value) public onlyOwner {
        nftsNumber = _value;
    }

    function setNftsPublicNumber(uint256 _value) public onlyOwner {
        nftsPublicNumber = _value;
    }

    function setBaseURI(string memory baseURIPrefix) public onlyOwner {
        _baseURIPrefix = baseURIPrefix;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIPrefix;
    }

    function safeMint(address to) public onlyOwner {
        _safeMint(to, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    whenNotPaused
    override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function directMint(address to, uint256 tokenId) public onlyOwner {
        require(tokenId > nftsPublicNumber, "Tokens number to mint must exceed number of public tokens");
        _safeMint(to, tokenId);
    }

    function buy(uint tokensNumber) whenNotPaused public payable {
        require(tokensNumber > 0, "Wrong amount");
        require(tokensNumber <= maxTokensPerTransaction, "Max tokens per transaction number exceeded");
        require(_tokenIdCounter.current().add(tokensNumber) <= nftsPublicNumber, "Tokens number to mint exceeds number of public tokens");
        uint256 amount = tokenPrice.mul(tokensNumber);
        uint256 balance = token.balanceOf(msg.sender);
        require( amount <= balance, "IRIS balance is too low");
        token.safeTransfer(address(this), amount);

        for(uint i = 0; i < tokensNumber; i++) {
            _safeMint(msg.sender, _tokenIdCounter.current());
            _tokenIdCounter.increment();
        }
    }
    function minted() external view returns(uint256){
        return _tokenIdCounter.current();
    }
    function withdraw() public onlyOwner {
        uint balance = token.balanceOf(address(this));
        token.safeTransfer(msg.sender, balance);
    }

}
