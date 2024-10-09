import "./App.css";
import { RouterProvider, createBrowserRouter } from "react-router-dom";
import { Home } from "./pages/home";
import { WalletTransfers } from "./pages/wallet/transfers/transfer";
import { WalletTransactions } from "./pages/wallet/transactions/transactions";
import { AssetsScreen } from "./pages/assets";

const router = createBrowserRouter([
  {
    path: "/",
    element: <Home />,
  },
  {
    path: "/wallet/transfers/:address",
    element: <WalletTransfers />,
  },
  {
    path: "/wallet/transactions/:address",
    element: <WalletTransactions />,
  },
  {
    path: "/wallet/assets/:address",
    element: <AssetsScreen />,
  },
]);

function App() {
  return <RouterProvider router={router} />;
}

export default App;
