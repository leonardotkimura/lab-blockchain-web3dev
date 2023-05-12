const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
    const gameContract = await gameContractFactory.deploy(
        ["Tetsuya Kuroko", "Taiga Kagami", "Shinji Koganei"],
            [
                "https://static.wikia.nocookie.net/kurokonobasuke/images/7/79/LG_Kuroko.png",
                "https://static.wikia.nocookie.net/kurokonobasuke/images/3/3f/LG_Kagami.png",
                "https://static.wikia.nocookie.net/kurokonobasuke/images/f/f4/Shinji_Koganei_anime.png",
            ],
        [50, 80, 80], // Stamina
        [30, 100, 80], // physical Ability
        [50, 80, 40], // Technique
        [100, 90, 70], // mental strength
        [100, 100, 40], // special ability
        "Seijuro Akashi",
        "https://static.wikia.nocookie.net/kurokonobasuke/images/7/78/Akashi_enters_the_Zone.png",
        1000,
        20
        );
    await gameContract.deployed();
    console.log("Contrato implantado no endereço:", gameContract.address)
  
    // let txn;
    // txn = await gameContract.mintCharacterNFT(2);
    // await txn.wait();

    // txn = await gameContract.attackBoss();
    // await txn.wait();

    // txn = await gameContract.attackBoss();
    // await txn.wait();

  
    console.log("Fim do deploy e mint!");
  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();