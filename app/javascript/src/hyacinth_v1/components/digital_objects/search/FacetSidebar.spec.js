import renderer from 'react-test-renderer';
import FacetDropdown from './facet_sidebar/FacetDropdown';
import FacetSidebar from './FacetSidebar';

jest.mock('./facet_sidebar/FacetDropdown', () => ({
  __esModule: true, default: jest.fn(() => 'FacetDropdown'),
}));

describe('FacetSidebar', () => {
  describe('selectedValuesFor', () => {
    it('flatmaps filter values by field name as key', () => {
      const selectedFacets = [
        { field: 'letters', values: ['a', 'b'] },
        { field: 'numbers', values: ['1', '2'] },
        { field: 'letters', values: ['c', 'd'] },
      ];
      const onFacetSelect = () => {};
      const facet = { fieldName: 'letters', values: [], displayLabel: 'Letters' };
      // expected props; key will not be included
      const expectedLetterProps = {
        facet,
        onFacetSelect,
        selectedValues: ['a', 'b', 'c', 'd'],
      };
      const expectedContext = {}; // no forward refs, etc.
      const component = renderer.create(
        FacetSidebar({ facets: [facet], onFacetSelect, selectedFacets }),
      );
      component.toJSON(); // actually build snapshot to call nested jsx/component functions
      expect(FacetDropdown).toHaveBeenCalledWith(expectedLetterProps, expectedContext);
    });
  });
});
