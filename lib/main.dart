import 'package:flutter/material.dart';
import 'package:solana/dto.dart' hide Instruction;
import 'package:solana/solana.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isError = false;
  RpcClient connection = RpcClient('https://api.devnet.solana.com');

  void playSolana() async {
    try {
      final SolanaClient solanaClient = SolanaClient(
        rpcUrl: Uri.parse('https://api.devnet.solana.com'),
        websocketUrl: Uri.parse('wss://api.devnet.solana.com'),
      );
      debugPrint("<<<<<<< Start InterSOL >>>>>>>");
      debugPrint("Lamport per SOL: $lamportsPerSol\n");
      final Ed25519HDKeyPair payer = await Ed25519HDKeyPair.fromMnemonic(
          'mad pony price voice infant ask next food gift aerobic analyst erode');
      final Ed25519HDKeyPair payee =
          await Ed25519HDKeyPair.fromMnemonic('I am Mr. Yor Loy');
      final Ed25519HDKeyPair mintAuth = await Ed25519HDKeyPair.fromMnemonic(
          'sting educate toward clump hammer seek move bone minimum vacuum category link');
      final Ed25519HDKeyPair freezeAuth = await Ed25519HDKeyPair.fromMnemonic(
          'sting educate toward clump hammer seek move bone minimum vacuum category link');
      debugPrint("Loading Wallet Successfully.\n");
      // debugPrint("Requesting Airdrop...");
      // await connection.requestAirdrop(
      //   payer.publicKey.toBase58(),
      //   lamportsPerSol,
      //   commitment: Commitment.confirmed,
      // );
      // sleep(const Duration(seconds: 30));
      // debugPrint("Requesting another airdrop for mint Auth");
      // await connection.requestAirdrop(
      //   mintAuth.publicKey.toBase58(),
      //   lamportsPerSol,
      //   commitment: Commitment.confirmed,
      // );
      // sleep(const Duration(seconds: 30));
      int payerBalance = await connection.getBalance(
        payer.publicKey.toBase58(),
        commitment: Commitment.confirmed,
      );
      int payeeBalance = await connection.getBalance(
        payee.publicKey.toBase58(),
        commitment: Commitment.confirmed,
      );
      debugPrint("Payer Account: ${payer.publicKey}");
      debugPrint("Payer Balance: $payerBalance");
      debugPrint("Payee Account: ${payee.publicKey}");
      debugPrint("Payee Balance: $payeeBalance\n");
      debugPrint("MintAuth Account: ${mintAuth.publicKey}");
      debugPrint("FreezeAuth Account: ${freezeAuth.publicKey}");

      debugPrint("Initialize Token...");
      final Mint token = await solanaClient.getMint(
        address: Ed25519HDPublicKey.fromBase58(
          'DbrcZHx94cW1SciQYNybbavkzsom4qE9wmKjF8znvksS',
        ),
        commitment: Commitment.confirmed,
      );
      //     await solanaClient.initializeMint(
      //   mintAuthority: mintAuth,
      //   freezeAuthority: freezeAuth.publicKey,
      //   decimals: 0,
      //   commitment: Commitment.confirmed,
      // );
      debugPrint("Done Init Token: ${token.address.toBase58()}\n");
      debugPrint("Getting or Creating Payer Account to Hold Token...");
      final ProgramAccount payerProgramAccount =
          await solanaClient.getAssociatedTokenAccount(
                owner: payer.publicKey,
                mint: token.address,
                commitment: Commitment.confirmed,
              ) ??
              await solanaClient.createAssociatedTokenAccount(
                owner: payer.publicKey,
                mint: token.address,
                funder: payer,
                commitment: Commitment.confirmed,
              );
      debugPrint("Payer ATA Account: ${payerProgramAccount.pubkey}");
      debugPrint("Getting or Creating Payee Account to Hold Token...");
      final ProgramAccount payeeProgramAccount =
          await solanaClient.getAssociatedTokenAccount(
                owner: payee.publicKey,
                mint: token.address,
                commitment: Commitment.confirmed,
              ) ??
              await solanaClient.createAssociatedTokenAccount(
                owner: payee.publicKey,
                mint: token.address,
                funder: payer,
                commitment: Commitment.confirmed,
              );
      debugPrint("Payee ATAAccount: ${payeeProgramAccount.pubkey}");
      debugPrint("Done Getting or Creating Accounts.\n");
      // debugPrint("Minting 1000000 Tokens to Payer Account...");
      // await solanaClient.mintTo(
      //   mint: token.address,
      //   destination: Ed25519HDPublicKey.fromBase58(payerProgramAccount.pubkey),
      //   amount: 1000000,
      //   authority: mintAuth,
      //   commitment: Commitment.confirmed,
      // );
      // debugPrint("Done Minting Token to Payer Account.");
      final TokenAmount tokenSupply =
          await solanaClient.rpcClient.getTokenSupply(
        token.address.toBase58(),
        commitment: Commitment.confirmed,
      );
      debugPrint("Total Supply of Token: ${tokenSupply.amount}\n");
      debugPrint("Transferring 50000 Token to Payee Account...");
      await solanaClient.transferSplToken(
        owner: payer,
        destination: payee.publicKey,
        amount: 50000,
        mint: token.address,
        commitment: Commitment.confirmed,
      );
      debugPrint("Done Transferring Token to Payee Account.\n");
      debugPrint("Getting Account Token Balances...");
      final payerTokenBalance =
          await solanaClient.rpcClient.getTokenAccountBalance(
        payerProgramAccount.pubkey,
        commitment: Commitment.confirmed,
      );
      final payeeTokenBalance =
          await solanaClient.rpcClient.getTokenAccountBalance(
        payeeProgramAccount.pubkey,
        commitment: Commitment.confirmed,
      );
      debugPrint("Payer Token Balance: ${payerTokenBalance.amount}");
      debugPrint("Payee Token Balance: ${payeeTokenBalance.amount}");
      debugPrint("<<<<<<< Done InterSOL >>>>>>>");
    } catch (e) {
      setState(() => isError = true);
    }
  }

  @override
  void initState() {
    super.initState();
    playSolana();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inter Solana',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Inter Solana'),
        ),
        body: Center(
          child: Text(
            'Integrate Solana APIs to Flutter App.\nCompleted: ${!isError ? 'True' : 'False'}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
