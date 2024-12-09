// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Gestionnaire des Risques de Contrepartie
 * @dev Ce contrat gère les contreparties, les expositions, les calculs de risques
 *      et les événements liés aux dépassements de limites.
 */
contract GestionnaireRisqueContrepartie {

    struct Contrepartie {
        uint256 scoreCredit;           // Score de crédit
        uint256 limiteExposition;      // Limite d'exposition maximale
        uint256 collateral;            // Montant de collatéral fourni
        bool estActif;                 // Statut actif de la contrepartie
    }

    mapping(address => Contrepartie) public contreparties;

    // Mapping to store net exposure between counterparties
    mapping(address => mapping(address => int256)) public expositionsNettes;

    // List of all counterparties
    address[] public listeContreparties;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Acces restreint au proprietaire");
        _;
    }

    event ContrepartieAjoutee(address indexed contrepartie, uint256 limiteExposition);
    event ExpositionMiseAJour(address indexed a, address indexed b, int256 exposition, uint256 timestamp);
    event LimiteDepassee(address indexed contrepartie, uint256 limite, uint256 timestamp);

    constructor() {
        owner = msg.sender;
    }

    function ajouterContrepartie(
        address _portefeuille,
        uint256 _scoreCredit,
        uint256 _limiteExposition,
        uint256 _collateral
    ) public onlyOwner {
        require(_portefeuille != address(0), "Adresse invalide");
        require(_scoreCredit > 0, "Score de credit invalide");
        require(_limiteExposition > 0, "Limite d'exposition invalide");
        require(!contreparties[_portefeuille].estActif, "Contrepartie deja enregistree");

        contreparties[_portefeuille] = Contrepartie({
            scoreCredit: _scoreCredit,
            limiteExposition: _limiteExposition,
            collateral: _collateral,
            estActif: true
        });

        // Add to the list of counterparties
        listeContreparties.push(_portefeuille);

        emit ContrepartieAjoutee(_portefeuille, _limiteExposition);
    }

    function mettreAJourExposition(
        address _a,
        address _b,
        uint256 _montant
    ) public onlyOwner {
        require(contreparties[_a].estActif, "Contrepartie A inactive");
        require(contreparties[_b].estActif, "Contrepartie B inactive");

        int256 expositionNetAB = expositionsNettes[_a][_b];
        int256 expositionNetBA = expositionsNettes[_b][_a];

        int256 nouvelleExpositionA = expositionNetAB + int256(_montant);
        int256 nouvelleExpositionB = expositionNetBA - int256(_montant);

        require(
            nouvelleExpositionA <= int256(contreparties[_a].limiteExposition),
            "Exposition depasse la limite de contrepartie A"
        );

        require(
            -nouvelleExpositionB <= int256(contreparties[_b].limiteExposition),
            "Exposition depasse la limite de contrepartie B"
        );

        expositionsNettes[_a][_b] = nouvelleExpositionA;
        expositionsNettes[_b][_a] = nouvelleExpositionB;

        emit ExpositionMiseAJour(_a, _b, nouvelleExpositionA, block.timestamp);
    }

    function calculerExpositionNet(address contrepartieA, address contrepartieB) public view returns (int256) {
        return expositionsNettes[contrepartieA][contrepartieB];
    }

    function calculerRatioCouverture(address _portefeuille) public view returns (uint256) {
        Contrepartie memory cp = contreparties[_portefeuille];
        require(cp.estActif, "Contrepartie inactive");

        int256 expositionNet = 0;

        // Sum up net exposures to all counterparties
        for (uint256 i = 0; i < listeContreparties.length; i++) {
            address autreContrepartie = listeContreparties[i];
            expositionNet += expositionsNettes[_portefeuille][autreContrepartie];
        }

        uint256 expositionNetPositive = uint256(expositionNet < 0 ? -expositionNet : expositionNet);

        if (expositionNetPositive > 0) {
            return (cp.collateral * 100) / expositionNetPositive;
        }
        return 0;
    }

    function calculerScoreRisque(address _portefeuille, address _recepteur) public view returns (uint256) {
        require(contreparties[_portefeuille].estActif, "Contrepartie inactive");
        require(contreparties[_recepteur].estActif, "Recepteur contrepartie inactive");

        Contrepartie memory cp = contreparties[_portefeuille];
        int256 expositionCourante = expositionsNettes[_portefeuille][_recepteur];

        require(expositionCourante >= 0, "Exposition courante ne peut pas etre negative");

        // Handle edge cases
        if (cp.limiteExposition == 0 || cp.scoreCredit == 0) {
            return 0; // Return 0 if inputs are invalid
        }

        // Perform calculations with higher precision
        uint256 firstPart = (uint256(expositionCourante) * 10000) / cp.limiteExposition; // Multiply by 10000 to preserve precision
        uint256 secondPart = 10000 / cp.scoreCredit; // Multiply by 10000 for precision

        // Combine both parts and divide by 10000 to restore the correct scale
        return (firstPart * secondPart) / 10000;
    }
}
