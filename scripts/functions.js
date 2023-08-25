const {
  toNumber,
  parseEther,
  Contract,
  JsonRpcProvider,
  Wallet,
  formatEther,
} = require("ethers");
const {
  contractAbi,
  contractAddress,
  accounts,
} = require("../utils/constants");

// Hardhat local network used here
const provider = new JsonRpcProvider("http://127.0.0.1:8545");

// @param key => private key of your account, default to first account when using hardhat local node
const getWallet = (key) => new Wallet(key || accounts[0].private, provider);

// @notice => register your account in the smart vault
// @param key => private key of your account, default to first account when using hardhat local node
const register = async (key) => {
  try {
    const wallet = getWallet(key);
    const contract = new Contract(contractAddress, contractAbi, provider);
    const walletContract = contract.connect(wallet);
    const register = await walletContract.register();
    await register.wait();
    console.log(register);
  } catch (error) {
    console.error(error);
  }
};

// @notice => get total amount in the smart contract(Vault)
const vault = async () => {
  try {
    const contract = new Contract(contractAddress, contractAbi, provider);
    const vault = await contract.vault();
    console.log("Total Amount In Vault is: ", formatEther(vault));
  } catch (error) {
    console.error(error);
  }
};

const myBalance = async () => {
  try {
    const contract = new Contract(contractAddress, contractAbi, provider);
    const bal = await contract.myBalance();
    console.log("Your balance is: ", toNumber(bal));
  } catch (error) {
    console.error(error);
  }
};

// @notice => get balance of an account within the vault
// @param address => address of the account to look up balance
const balanceOf = async (address) => {
  try {
    const contract = new Contract(contractAddress, contractAbi, provider);
    const bal = await contract.balanceOf(address);
    console.log(`${address} balance is: ${formatEther(bal)}`);
  } catch (error) {
    console.error(error);
  }
};

// @notice => get details of an account within the vault
// @param address => address of the account to look up balance
const getUser = async (address) => {
  try {
    const contract = new Contract(contractAddress, contractAbi, provider);
    const user = await contract.getUser(address);
    console.log(
      `${address} details: ${JSON.stringify({
        address: user[0],
        balance: formatEther(user[1]) + " ethers",
      })}`
    );
  } catch (error) {
    console.error(error);
  }
};

// @notice => get details of an account within the vault
// @param key => private key of your account, default to first account
// @param to => address to transfer fund to within the contract
// @param amount => amount to transfer
const transfer = async (key, to, amount) => {
  try {
    const wallet = getWallet(key);
    const contract = new Contract(contractAddress, contractAbi, provider);
    const walletContract = contract.connect(wallet);
    const transfer = await walletContract.transfer(to, parseEther(amount));
    await transfer.wait();
    console.log(transfer);
  } catch (error) {
    console.error(error);
  }
};

// @notice => withdraw fund from vault to account
// @param key => private key of your account, default to first account
// @param amount => amount to withdraw from vault
const withdraw = async (key, amount) => {
  try {
    const wallet = getWallet(key);
    const contract = new Contract(contractAddress, contractAbi, provider);
    const walletContract = contract.connect(wallet);
    const withdraw = await walletContract.withdraw(parseEther(amount));
    await withdraw.wait();
    console.log(withdraw);
  } catch (error) {
    console.error(error);
  }
};

// @notice => deposit fund into vault from your account
// @param key => private key of your account, default to first account
// @param amount => amount to deposit into vault
const deposit = async (key, amount) => {
  try {
    const wallet = getWallet(key);
    const contract = new Contract(contractAddress, contractAbi, provider);
    const walletContract = contract.connect(wallet);
    const deposit = await walletContract.deposit({ value: parseEther(amount) });
    await deposit.wait();
    console.log(deposit);
  } catch (error) {
    console.error(error);
  }
};

module.exports = {
  register,
  myBalance,
  balanceOf,
  deposit,
  withdraw,
  transfer,
  vault,
  getUser,
};
