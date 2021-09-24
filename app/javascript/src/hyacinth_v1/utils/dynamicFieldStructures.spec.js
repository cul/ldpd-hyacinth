import { emptyDataForCategories, filterDynamicFieldCategories, padForEnabledFields } from './dynamicFieldStructures';

describe('dynamicFieldStructures', () => {
  const categoryExample = {
    children: [
      {
        stringKey: 'levelOneEnabledField',
        type: 'DynamicField',
        fieldType: 'boolean',
        id: 2,
      },
      {
        stringKey: 'levelOneDisallowedField',
        type: 'DynamicField',
        fieldType: 'boolean',
        id: 3,
      },
      {
        stringKey: 'levelOneGroup',
        type: 'DynamicFieldGroup',
        children: [
          {
            stringKey: 'levelTwoEnabledField',
            type: 'DynamicField',
            fieldType: 'boolean',
            id: 4,
          },
          {
            stringKey: 'levelTwoDisallowedField',
            type: 'DynamicField',
            fieldType: 'boolean',
            id: 5,
          },
          {
            stringKey: 'levelTwoGroup',
            type: 'DynamicFieldGroup',
            children: [
              {
                stringKey: 'levelThreeEnabledField',
                type: 'DynamicField',
                fieldType: 'boolean',
                id: 6,
              },
              {
                stringKey: 'levelThreeDisallowedField',
                type: 'DynamicField',
                fieldType: 'boolean',
                id: 7,
              },
              {
                stringKey: 'levelThreeGroup',
                type: 'DynamicFieldGroup',
                children: [
                  {
                    stringKey: 'levelFourEnabledField',
                    type: 'DynamicField',
                    fieldType: 'boolean',
                    id: 8,
                  },
                  {
                    stringKey: 'levelFourDisallowedField',
                    type: 'DynamicField',
                    fieldType: 'boolean',
                    id: 9,
                  },
                ],
              },
            ],
          },
        ],
      },
    ],
  };

  const disallowedCategoryExample = {
    children: [
      {
        stringKey: 'rogueDisallowedField',
        type: 'DynamicField',
        fieldType: 'boolean',
        id: 11,
      },
    ],
  };

  const emptyDataExample = {
    levelOneEnabledField: false,
    levelOneGroup: [
      {
        levelTwoEnabledField: false,
        levelTwoGroup: [
          {
            levelThreeEnabledField: false,
            levelThreeGroup: [
              { levelFourEnabledField: false },
            ],
          },
        ],
      },
    ],
  };

  const enabledDynamicFieldsExample = [2, 4, 6, 8].map((i) => ({ dynamicField: { id: i }, enabled: true }));

  const enabledCategoriesExample = [
    {
      children: [
        {
          type: 'DynamicField',
          stringKey: 'levelOneEnabledField',
          fieldType: 'boolean',
          id: 2,
        },
        {
          stringKey: 'levelOneGroup',
          type: 'DynamicFieldGroup',
          children: [
            {
              stringKey: 'levelTwoEnabledField',
              type: 'DynamicField',
              fieldType: 'boolean',
              id: 4,
            },
            {
              stringKey: 'levelTwoGroup',
              type: 'DynamicFieldGroup',
              children: [
                {
                  stringKey: 'levelThreeEnabledField',
                  type: 'DynamicField',
                  fieldType: 'boolean',
                  id: 6,
                },
                {
                  stringKey: 'levelThreeGroup',
                  type: 'DynamicFieldGroup',
                  children: [
                    {
                      stringKey: 'levelFourEnabledField',
                      type: 'DynamicField',
                      fieldType: 'boolean',
                      id: 8,
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
    },
  ];

  const descriptiveMetadataExample = {
    levelOneGroup: [
      {
        levelTwoGroup: [
          {
            levelThreeEnabledField: true,
          },
          {
            levelThreeEnabledField: true,
            levelThreeGroup: [
              {
                levelFourEnabledField: true,
              },
            ],
          },
          {
            levelThreeEnabledField: false,
          },
        ],
      },
    ],
  };

  describe('emptyDataForCategories', () => {
    it('returns a deep structure of default data', () => {
      expect(emptyDataForCategories(enabledCategoriesExample)).toEqual(emptyDataExample);
    });
  });

  describe('filterDynamicFieldCategories', () => {
    it('returns categories filtered of disallowed fields and pruned when empty', () => {
      const categoriesExample = [categoryExample, disallowedCategoryExample];
      const categories = JSON.parse(JSON.stringify(categoriesExample));
      expect(filterDynamicFieldCategories(categories, enabledDynamicFieldsExample)).toEqual(enabledCategoriesExample);
    });
  });

  describe('padForEnabledFields', () => {
    it('expectation tbd', () => {
      const descriptiveData = JSON.parse(JSON.stringify(descriptiveMetadataExample));
      const paddedData = padForEnabledFields(descriptiveData, emptyDataExample);
      const { levelOneGroup: [{ levelTwoGroup }] } = paddedData;
      const deepValues = levelTwoGroup.map((x) => x.levelThreeGroup[0].levelFourEnabledField);
      expect(deepValues).toEqual([false, true, false]);
    });
  });
});
