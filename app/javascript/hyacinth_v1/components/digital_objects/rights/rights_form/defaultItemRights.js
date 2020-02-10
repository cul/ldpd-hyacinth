const defaultItemRights = () => (
  {
    descriptiveMetadata: {
      typeOfContent: '',
      countryOfOrigin: {},
      filmDistributedToPublic: '',
      filmDistributedCommercially: '',
    },
    copyrightStatus: {
      copyrightStatement: '',
      copyrightNote: [''],
      copyrightRegistered: '',
      copyrightRenewed: '',
      copyrightDateOfRenewal: '',
      copyrightExpirationDate: '',
      culCopyrightAssessmentDate: '',
    },
    additionalRightsToRecord: {
      enabled: false,
    },
    copyrightOwnership: {
      enabled: false,
      copyrightOwners: [
        {
          name: {},
          heirs: '',
          contactInformation: '',
        },
      ],
    },
    columbiaUniversityIsCopyrightHolder: {
      enabled: false,
      dateOfTransfer: '',
      dateOfExpiration: '',
      transferDocumentionEnabled: false,
      transferDocumentation: '',
      otherTransferEvidenceEnabled: false,
      otherTransferEvidence: '',
      transferDocumentationNote: '',
    },
    licensedToColumbiaUniversity: {
      enabled: false,
      dateOfLicense: '',
      terminationDateOfLicense: '',
      credits: '',
      acknowledgements: '',
      licenseDocumentationLocation: '',
    },
    contractualLimitationsRestrictionsAndPermissions: {
      a: false,
      b: false,
      c: false,
      d: false,
      e: false,
      avA: false,
      avB: false,
      avC: false,
      avD: false,
      avE: false,
      avF: false,
      avG: false,
      enabled: false,
      reproductionAndDistributionProhibitedUntil: '',
      photoGraphicOrFilmCredit: '',
      excerptLimitedTo: '',
      other: '',
      permissionsGrantedAsPartOfTheUseLicenseEnabled: false,
      permissionsGrantedAsPartOfTheUseLicense: [],
    },
    rightsForWorksOfArtSculptureAndPhotographs: {
      enabled: false,
      publicityRightsPresentEnabled: false,
      publicityRightsPresent: '',
      trademarksProminentlyVisible: '',
      sensitiveInNature: '',
      privacyConcerns: '',
      childrenMateriallyIdentifiableInWork: '',
      varaRightsConcerns: '',
      note: '',
    },
    underlyingRights: {
      enabled: false,
      doWeKnowSpecificUnderlyingRightsEnabled: false,
      note: '',
      musicRightsEnabled: false,
      talentRights: '',
      musicLicensedToColumbiaEnabled: false,
      columbiaMusicLicense: '',
      composition: '',
      recording: '',
      otherUnderlyingRights: [],
      other: '',
    },
  }
);

const itemRightsSelectors = () => (
  ""
 // `{${defaultItemRights().keys().join(',')}}`
);

export { itemRightsSelectors, defaultItemRights };
