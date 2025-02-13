// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenTimelock is Ownable {
  using SafeERC20 for IERC20;
  IERC20 public token;
  uint public immutable ENTRY_PRICE = 0.1 ether;
  uint public immutable AMOUNT_PER_UNLOCK = 10 ether;
  uint public immutable UNLOCK_COUNT = 3;

  mapping(uint8 => uint256) public unlock_time;
  mapping(address => bool) public is_beneficiary;
  mapping(address => mapping(uint256 => bool)) public beneficiary_has_claimed;

  constructor()
  {
    token = IERC20(0x0000000000000000000000000000000000000000);

    unlock_time[0] = block.timestamp + 1 days;
    unlock_time[1] = block.timestamp + 20 days;
    unlock_time[2] = block.timestamp + 40 days;
  }

  function claim(uint8 unlock_number) public {
    require(unlock_number < UNLOCK_COUNT, "Must be below unlock count.");
    require(block.timestamp >= unlock_time[unlock_number], "Must have reached unlock time.");
    require(is_beneficiary[msg.sender], "Beneficiary must has bought.");
    require(beneficiary_has_claimed[msg.sender][unlock_number] == false, "Beneficiary should not have claimed.");

    beneficiary_has_claimed[msg.sender][unlock_number] = true;

    token.safeTransferFrom(address(this),msg.sender, AMOUNT_PER_UNLOCK);
  }

  function buy() public payable
  {
    require(msg.value == ENTRY_PRICE, "Must pay the entry price.");
    is_beneficiary[msg.sender] = true;
  }

  function withdraw() public
  {
    (bool sent, bytes memory data) = address(owner()).call{value: address(this).balance}("");
    require(sent, "Failed to send Ether");
    data;
  }
}
