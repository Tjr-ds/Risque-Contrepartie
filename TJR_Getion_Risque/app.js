const contractAddress = "0xcab50D17fB6d3F663477b990d55eEc5F7A553Dff";
const contractABI = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_portefeuille",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_scoreCredit",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_limiteExposition",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_collateral",
				"type": "uint256"
			}
		],
		"name": "ajouterContrepartie",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "contrepartie",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "limiteExposition",
				"type": "uint256"
			}
		],
		"name": "ContrepartieAjoutee",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "a",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "b",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "int256",
				"name": "exposition",
				"type": "int256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "ExpositionMiseAJour",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "contrepartie",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "limite",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "LimiteDepassee",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_a",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_b",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_montant",
				"type": "uint256"
			}
		],
		"name": "mettreAJourExposition",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "contrepartieA",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "contrepartieB",
				"type": "address"
			}
		],
		"name": "calculerExpositionNet",
		"outputs": [
			{
				"internalType": "int256",
				"name": "",
				"type": "int256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_portefeuille",
				"type": "address"
			}
		],
		"name": "calculerRatioCouverture",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_portefeuille",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_recepteur",
				"type": "address"
			}
		],
		"name": "calculerScoreRisque",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "contreparties",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "scoreCredit",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "limiteExposition",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "collateral",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "estActif",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "expositionsNettes",
		"outputs": [
			{
				"internalType": "int256",
				"name": "",
				"type": "int256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "listeContreparties",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];

let web3;
let contract;

window.onload = async () => {
    if (window.ethereum) {
        web3 = new Web3(window.ethereum);
        await window.ethereum.enable();
        contract = new web3.eth.Contract(contractABI, contractAddress);
        console.log("Connected to contract");
    } else {
        alert("Please install MetaMask to interact with this application.");
    }
};

async function ajouterContrepartie() {
    const address = document.getElementById("ajouterAdresse").value;
    const scoreCredit = parseInt(document.getElementById("ajouterScoreCredit").value);
    const limiteExposition = parseInt(document.getElementById("ajouterLimiteExposition").value);
    const collateral = parseInt(document.getElementById("ajouterCollateral").value);

    try {
        const accounts = await web3.eth.getAccounts();
        await contract.methods
            .ajouterContrepartie(address, scoreCredit, limiteExposition, collateral)
            .send({ from: accounts[0] });

        alert("Contrepartie ajoutée avec succès !");
    } catch (error) {
        console.error("Erreur:", error);
        alert(`Erreur lors de l'ajout de la contrepartie: ${error.message}`);
    }
}

async function mettreAJourExposition() {
    const a = document.getElementById("expositionA").value;
    const b = document.getElementById("expositionB").value;
    const montant = parseInt(document.getElementById("montantExposition").value);

    try {
        const accounts = await web3.eth.getAccounts();
        await contract.methods
            .mettreAJourExposition(a, b, montant)
            .send({ from: accounts[0] });
        alert("Exposition mise à jour !");
    } catch (error) {
        console.error("Erreur:", error);
        alert(`Erreur lors de la mise à jour de l'exposition: ${error.message}`);
    }
}

async function calculerExpositionNet() {
    const a = document.getElementById("netExpositionA").value;
    const b = document.getElementById("netExpositionB").value;

    try {
        const result = await contract.methods.calculerExpositionNet(a, b).call();
        document.getElementById("resultatExpositionNet").innerText = `Exposition nette : ${result}`;
    } catch (error) {
        console.error("Erreur:", error);
        alert(`Erreur lors du calcul de l'exposition nette: ${error.message}`);
    }
}

async function calculerRatioCouverture() {
    const address = document.getElementById("calculerRatioAdresse").value;

    try {
        const result = await contract.methods.calculerRatioCouverture(address).call();
        document.getElementById("resultatRatio").innerText = `Ratio de couverture : ${result}%`;
    } catch (error) {
        console.error("Erreur:", error);
        alert(`Erreur lors du calcul du ratio de couverture: ${error.message}`);
    }
}

async function calculerScoreRisque() {
    const a = document.getElementById("scoreRisqueA").value;
    const b = document.getElementById("scoreRisqueB").value;

    try {
        const result = await contract.methods.calculerScoreRisque(a, b).call();
        document.getElementById("resultatScore").innerText = `Score de risque : ${result}`;
    } catch (error) {
        console.error("Erreur:", error);
        alert(`Erreur lors du calcul du score de risque: ${error.message}`);
    }
}

async function obtenirDetailsContrepartie() {
    const address = document.getElementById("detailsAdresse").value;

    try {
        const contrepartie = await contract.methods.contreparties(address).call();
        if (contrepartie.estActif) {
            document.getElementById("detailsContrepartie").innerHTML = `
                <strong>Score de Crédit :</strong> ${contrepartie.scoreCredit}<br>
                <strong>Limite d'Exposition :</strong> ${contrepartie.limiteExposition}<br>
                <strong>Collatéral :</strong> ${contrepartie.collateral}<br>
                <strong>Statut :</strong> Actif
            `;
        } else {
            document.getElementById("detailsContrepartie").innerText = "Contrepartie inactive ou non trouvée.";
        }
    } catch (error) {
        console.error("Erreur:", error);
        alert(`Erreur lors de la récupération des détails de la contrepartie: ${error.message}`);
    }
}
