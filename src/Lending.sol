// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IPriceOracle {
    function getPrice(address token) external view returns (uint256);
}

contract Lending {
    IPriceOracle public oracle;
    ERC20 public usdc;

    bool public initiator = false;
    mapping(address => uint256) public userETH;
    mapping(address => uint256) public userUSDC;
    mapping(address => uint256) public borrowedUSDC;
    mapping(address => uint256) public recentBlock; // 1 block 당 12sec 고정으로 계산하세요.

    constructor(IPriceOracle _oracle, address _usdc) {
        oracle = _oracle;
        usdc = ERC20(_usdc);
    }

    function initializeLendingProtocol(address token) external payable {
        require(!initiator && msg.value == 1, "Give Me 1 CUSDC");
        usdc.transferFrom(msg.sender, address(this), msg.value);
        initiator = true;
    }

    function deposit(address token, uint256 amount) external payable {
        if (token == address(0)) {
            require(msg.value == amount, "Insufficient Ether");
            userETH[msg.sender] += msg.value;
        } else {
            require(usdc.balanceOf(msg.sender) >= amount, "Insufficient USDC");
            usdc.transferFrom(msg.sender, address(this), amount);
            userUSDC[msg.sender] += amount;
        }
    }

    function borrow(address token, uint256 amount) external {

        uint256 ethP = oracle.getPrice(address(0));
        uint256 usdP = oracle.getPrice(address(usdc));
        uint256 available = (userETH[msg.sender] * ethP + userUSDC[msg.sender] * usdP) * 66 / 100 - borrowedUSDC[msg.sender] * usdP;
        require(available >= amount * oracle.getPrice(address(token)), "Nanananana");

        borrowedUSDC[msg.sender] += amount;
        usdc.transfer(msg.sender, amount);
    }

    function repay(address token, uint256 amount) external {
    }

    function withdraw(address token, uint256 amount) external {
    }

    function getAccruedSupplyAmount(address token) external view returns (uint256) {
    }

    function liquidate(address _usdc, address _borrower) external {

    }
}
