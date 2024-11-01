import { useEffect, useState } from "react";
import { ApprovalsList } from "../components/ApprovalsList";
import { Layout } from "../components/Layout";
import { NoWalletConnected } from "../components/NoWalletConnected";
import { useAccount } from "../context/UserContext";
import { ASSETS } from "../utils/constants";
import { ERC20 } from "../utils/ERC20";
import { formatEther } from "ethers";
import { Balance, WalletDetails } from "../utils/type";
import { getMultiSig } from "../utils/MultiSigWallet";
import { Link } from "react-router-dom";
import { Loader } from "../components/Loader";
import { NotAnApproval } from "../components/NotAnApproval";

export function AssetsScreen() {
  const account = useAccount();
  const [uiState, setUiState] = useState({
    loading: false,
    showModal: false,
    loadingData: false,
  });

  const [balances, setBalances] = useState<Balance[]>([]);

  useEffect(() => {
    _getBalance();
  }, [account?.address, account?.provider]);

  useEffect(() => {
    _getWallet();
  }, [account?.address, account?.provider]);

  // useEffect(() => {
  //   _getWallet();
  // }, [account?.address, account?.provider]);

  async function getWalletDetails(address: string) {
    try {
      // if (!account || !account.provider) return
      const instance = getMultiSig(account?.provider, address);

      const promise = Promise.all([
        instance.getName(),
        instance.getApprovers(),
        account?.provider?.eth.getBalance(address),
      ]);
      const [name, approvals, balance] = await promise;
      const balanceInEth: string = account?.provider?.utils.fromWei(
        balance,
        "ether"
      );
      const detail: WalletDetails = {
        address: address,
        name,
        approvals,
        balance: +(+balanceInEth).toFixed(3),
      };
      return { detail };
    } catch (error) {
      throw error;
    }
  }

  async function _getWallet() {
    if (!account) return;
    if (!account.address || !account.provider) return;
    const walletAddress = location.pathname.split("/").pop();
    if (!walletAddress) return;
    try {
      setUiState({ ...uiState, loadingData: true });
      // const { detail, _transfers } = await getWalletDetails(walletAddress);

      const { detail } = await getWalletDetails(walletAddress);

      account.updateWallet(detail);

      setUiState({ ...uiState, loadingData: false });
    } catch (error) {
      console.log(error);
      setUiState({ ...uiState, loadingData: false });
    }
  }

  async function _getBalance() {
    if (!account) return;
    if (!account.address || !account.provider) return;
    const walletAddress = location.pathname.split("/").pop();
    if (!walletAddress) return;
    try {
      setUiState({ ...uiState, loadingData: true });
      // const { detail, _transfers } = await getWalletDetails(walletAddress);

      const _balances = await Promise.all(
        ASSETS.map(async (a) => {
          if (a.symbol === "RWA") {
            const balance = await account.provider.eth.getBalance(
              walletAddress
            );
            return {
              symbol: a.symbol,
              balance: +formatEther(balance),
              token: a.token,
            };
          } else {
            const balance = await ERC20.balanceOf(
              account.provider,
              a.token,
              walletAddress
            );
            return {
              balance,
              symbol: a.symbol,
              token: a.token,
            };
          }
        })
      );

      //   account.updateWallet(detail);
      setBalances([..._balances]);
      setUiState({ ...uiState, loadingData: false });
    } catch (error) {
      console.log(error);
      setUiState({ ...uiState, loadingData: false });
    }
  }

  function render() {
    if (!account || !account.address) {
      return <NoWalletConnected />;
    }
    if (uiState.loadingData) {
      return (
        <div className="flex items-center justify-center w-full h-full">
          <Loader />
        </div>
      );
    }

    if (
      !account.wallet ||
      !account.wallet.approvals.some(
        (approval) => approval.toLowerCase() === account.address!.toLowerCase()
      )
    )
      return <NotAnApproval />;

    return (
      <div className="flex flex-col w-full">
        <ApprovalsList
          approvals={account && account.wallet ? account.wallet.approvals : []}
        />
        <div className="flex flex-col w-full overflow-y-auto px-5 py-5">
          <table className="w-full text-left text-sm text-slate-500  rtl:text-right">
            <thead className="bg-blue-50 text-xs uppercase ">
              <tr>
                <th scope="col" className="px-6 py-3">
                  ID
                </th>
                <th scope="col" className="px-6 py-3">
                  Asset
                </th>
                <th scope="col" className="px-6 py-3">
                  Balance
                </th>
                <th scope="col" className="px-6 py-3">
                  Action
                </th>
              </tr>
            </thead>
            <tbody>
              {balances.length > 0 &&
                balances.map((e, i) => (
                  <tr
                    key={i}
                    className="border-b bg-white-50 hover:bg-blue-50 cursor-pointer"
                  >
                    <td
                      scope="row"
                      className="whitespace-nowrap px-6 py-4 font-medium"
                    >
                      {i + 1}
                    </td>
                    <td className="px-6 py-4">{e.symbol}</td>
                    <td className="px-6 py-4">
                      {e.balance.toFixed(3)} {e.symbol}
                    </td>

                    <td className="px-6 py-4">
                      <Link
                        to={`/wallet/transfers/${account.wallet?.address}?token=${e.symbol}`}
                      >
                        <button
                          className="text-nowrap rounded-lg mt-6 w-full px-3 py-3 text-[16px]/[20px] text-white capitalize bg-blue-400"
                          //   disabled={uiState.loading || e.sent}
                        >
                          Send
                        </button>
                      </Link>
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>
      </div>
    );
  }
  return (
    <Layout>
      <div className="flex w-full h-full bg-white">
        {render()}
      </div>
    </Layout>
  );
}
