// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Gestionnaire des Risques de Contrepartie
 * @dev Ce contrat gère les contreparties, les expositions, les calculs de risques
 *      et les événements liés aux dépassements de limites.
 */
contract GestionnaireRisqueContrepartie {

    struct Contrepartie {
        address portefeuille;          // Adresse de la contrepartie
        uint256 scoreCredit;           // Score de crédit
        uint256 limiteExposition;      // Limite d'exposition maximale
        uint256 expositionCourante;    // Exposition actuelle
        uint256 collateral;            // Montant de collatéral fourni
        bool estActif;                 // Statut actif de la contrepartie
    }

    mapping(address => Contrepartie) public contreparties;

    // Exposition totale de toutes les contreparties
    uint256 public totalExposure;

    address public owner;
    address public emetteur;

    modifier onlyOwner() {
        require(msg.sender == owner, "Acces restreint au proprietaire");
        _;
    }

    event ContrepartieAjoutee(address indexed contrepartie, uint256 limiteExposition);
    event ExpositionMiseAJour(address indexed contrepartie, uint256 nouvelleExposition, uint256 timestamp);
    event LimiteDepassee(address indexed contrepartie, uint256 exposition, uint256 limite, uint256 timestamp);

    constructor(address _emetteur) {
        require(_emetteur != address(0), "Adresse emetteur invalide");
        owner = msg.sender;
        emetteur = _emetteur;
    }

    function modifierEmetteur(address _nouvelEmetteur) public onlyOwner {
        require(_nouvelEmetteur != address(0), "Nouvelle adresse emetteur invalide");
        emetteur = _nouvelEmetteur;
    }

    function ajouterContrepartie(
        address _portefeuille,
        uint256 _scoreCredit,
        uint256 _limiteExposition,
        uint256 _expositionCourante,
        uint256 _collateral
    ) public onlyOwner {
        require(_portefeuille != address(0), "Adresse invalide");
        require(_scoreCredit > 0, "Score de credit invalide");
        require(_limiteExposition > 0, "Limite d'exposition invalide");
        require(_expositionCourante <= _limiteExposition, "Exposition courante depasse la limite");
        require(!contreparties[_portefeuille].estActif, "Contrepartie deja enregistree");

        contreparties[_portefeuille] = Contrepartie({
            portefeuille: _portefeuille,
            scoreCredit: _scoreCredit,
            limiteExposition: _limiteExposition,
            expositionCourante: _expositionCourante,
            collateral: _collateral,
            estActif: true
        });

        // Ajouter l'exposition courante à l'exposition totale
        totalExposure += _expositionCourante;

        emit ContrepartieAjoutee(_portefeuille, _limiteExposition);
    }

    function mettreAJourExposition(address _portefeuille, uint256 _exposition) public {
        require(contreparties[_portefeuille].estActif, "Contrepartie inactive");
        require(_exposition <= contreparties[_portefeuille].limiteExposition, "Exposition depasse la limite autorisee");

        Contrepartie storage cp = contreparties[_portefeuille];

        // Mettre à jour l'exposition totale
        totalExposure = totalExposure - cp.expositionCourante + _exposition;

        cp.expositionCourante = _exposition;

        if (cp.expositionCourante > cp.limiteExposition) {
            emit LimiteDepassee(_portefeuille, cp.expositionCourante, cp.limiteExposition, block.timestamp);
        } else {
            emit ExpositionMiseAJour(_portefeuille, _exposition, block.timestamp);
        }
    }

    function calculerRatioCouverture(address _portefeuille) public view returns (uint256) {
        Contrepartie memory cp = contreparties[_portefeuille];
        require(cp.estActif, "Contrepartie inactive");
        if (cp.expositionCourante > 0) {
            return (cp.collateral * 100) / cp.expositionCourante;
        }
        return 0;
    }

    function calculerScoreRisque(address _portefeuille) public view returns (uint256) {
        require(contreparties[_portefeuille].estActif, "Contrepartie inactive");

        Contrepartie memory cp = contreparties[_portefeuille];

        // Handle edge cases
        if (cp.limiteExposition == 0 || cp.scoreCredit == 0) {
            return 0; // Return 0 if inputs are invalid
        }

        // Simplified calculation
        uint256 firstPart = (cp.expositionCourante * 100) / cp.limiteExposition; // In percentage
        uint256 secondPart = 100 / cp.scoreCredit; // Also in percentage

        // Combine both parts and multiply the result by 100
        return (firstPart * secondPart);
    }
}
