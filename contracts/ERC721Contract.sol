// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERC721Contract is ERC721, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIdCounter;

    string public baseURI = "ipfs://.../";
    string public hiddenURI = "ipfs://.../hidden.json";

    uint256 public price = 0.01 ether;

    bool public mintState = false;
    bool public revealState = false;

    mapping(address => uint256) addressMintAmount;

    uint256 public maxSupply = 10;
    uint256 public maxMintAmount = 10;
    uint256 public maxMintAmountPerAddress = 2;
    uint256 public maxMintAmountPerTx = 2;

    address public founder1 = 0x0000000000000000000000000000000000000000;
    address public founder2 = 0x0000000000000000000000000000000000000000;
    address public communityAndPartners = 0x0000000000000000000000000000000000000000;
    address public treasury = 0x0000000000000000000000000000000000000000;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _hiddenURI() internal view returns (string memory) {
        return hiddenURI;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "NFT with this token id doesn't exist.");
        require(tokenId > 0 && tokenId <= maxSupply, "NFT with this token id doesn't exist.");

        if(revealState == false) {
            string memory currentHiddenURI = _hiddenURI();
            return currentHiddenURI;
        } else {
            string memory currentBaseURI = _baseURI();
            return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), ".json")) : "";
        }
    } 

    function updateBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

    function updateHiddenURI(string memory newHiddenURI) public onlyOwner {
        hiddenURI = newHiddenURI;
    }

    function setRevealState(bool newState) public onlyOwner {
        revealState = newState;
    }
    
    function setMintState(bool newState) public onlyOwner {
        mintState = newState;
    }

    function setPrice(uint256 newPrice) public onlyOwner {
       price = newPrice;
    }

    function ownerMint(uint256 amount) public onlyOwner {
        require(amount > 0, "Not enough amount");

        uint256 currentSupply = _tokenIdCounter.current();
        require(currentSupply + amount <= maxSupply, "Max supply limit exceeded.");

        for (uint256 i = 0; i < amount; i++) {
            addressMintAmount[msg.sender]++;
            _tokenIdCounter.increment();
            _safeMint(msg.sender, _tokenIdCounter.current());
        }
    }

    function mint(uint256 amount) public payable {
        require(mintState == true, "Mint deactivated.");

        require(msg.sender == tx.origin, "Not allowed origin.");

        require(amount > 0, "Not enough amount.");
        require(msg.value >= price * amount, "Insufficient funds.");

        uint256 currentSupply = _tokenIdCounter.current();
        uint256 currentAddressMintAmount = addressMintAmount[msg.sender];

        require(currentSupply + amount <= maxSupply, "Max supply limit exceeded.");
        require(currentSupply + amount <= maxMintAmount, "Max mint amount exceeded.");
        require(currentAddressMintAmount + amount <= maxMintAmountPerAddress, "Max mint amount per address exceeded.");
        require(amount <= maxMintAmountPerTx, "Max mint amount per transaction exceeded.");

        for (uint256 i = 0; i < amount; i++) {
            addressMintAmount[msg.sender]++;
            _tokenIdCounter.increment();
            _safeMint(msg.sender, _tokenIdCounter.current());
        }
    }

    function updateMaxMintAmountPerAddress(uint256 newAmount) public onlyOwner {
        maxMintAmountPerAddress = newAmount;
    }

    function updateMaxMintAmountPerTx(uint256 newAmount) public onlyOwner {
        maxMintAmountPerTx = newAmount;
    }

    function updateMaxMintAmount(uint256 newAmount) public onlyOwner {
        maxMintAmount = newAmount;
    }

    function withdraw() public payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Not enough balance.");

        (bool successFounder1, ) = payable(founder1).call{value: ((balance * 250) / 1000)}("");
        require(successFounder1, "Transfer failed.");

        (bool successFounder2, ) = payable(founder2).call{value: ((balance * 250) / 1000)}("");
        require(successFounder2, "Transfer failed.");

        (bool successCommunityAndPartners, ) = payable(communityAndPartners).call{value: ((balance * 250) / 1000)}("");
        require(successCommunityAndPartners, "Transfer failed.");

        (bool successTreasury, ) = payable(treasury).call{value: ((balance * 250) / 1000)}("");
        require(successTreasury, "Transfer failed.");

        (bool successOwner, ) = payable(msg.sender).call{value: (address(this).balance)}("");
        require(successOwner, "Transfer failed.");
    }

    function tokensOfOwner(address _address, uint startId, uint endId) external view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(_address);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index = 0;

            for (uint256 tokenId = startId; tokenId < endId; tokenId++) {
                if (index == tokenCount) break;

                if (ownerOf(tokenId) == _address) {
                    result[index] = tokenId;
                    index++;
                }
            }
            return result;
        }
    }

    function getAddressMintAmount(address _address) external view returns (uint) {
        return addressMintAmount[_address];
    }

    function getAddressBalance(address _address) external view returns (uint) {
        return balanceOf(_address);
    }

    function totalSupply() public view returns (uint) {
        return _tokenIdCounter.current();
    }
}
