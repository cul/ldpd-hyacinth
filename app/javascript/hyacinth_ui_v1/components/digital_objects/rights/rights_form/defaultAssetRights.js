const defaultAssetRights = () => (
  {
    restrictionOnAccess: {
      value: '', // This eventually needs to be multivalued.
      embargoRelease: '',
      note: '',
      location: [],
      affiliation: [],
    },
    copyrightStatusOverride: {
      copyrightStatement: '',
      copyrightNote: [''],
      copyrightRegistered: '',
      copyrightRenewed: '',
      copyrightDateOfRenewal: '',
      copyrightExpirationDate: '',
      culCopyrightAssessmentDate: '',
    },
  }
);

const assetRightsSelectors = () => (
  `{${defaultAssetRights().keys().join(',')}}`
);

export { assetRightsSelectors, defaultAssetRights };
