import FacetSlideOut, { facetSearchVariables } from './FacetSlideOut';
import { cloneDeep } from 'lodash';

const templateSearchParams = {
  searchTerms: 'Search Terms',
  searchType: 'KEYWORD',
  filters: [
    {
      field: 'other_field',
      matchType: 'EQUALS',
      values: ['Other Field Value'],
    }
  ],
}

const sessionSearchParams = () => cloneDeep(templateSearchParams);


jest.mock('./FacetSlideOut', () => {
  const originalModule = jest.requireActual('./FacetSlideOut');
  return {
    __esModule: true,
    ...originalModule,
    objectSearchParams: jest.fn(() => sessionSearchParams()),
  };
});

describe('FacetSlideOut', () => {
  describe('facetSearchVariables', () => {
    const fieldName = 'facet_field';
    const facetFilter = { filterValue: 'FILTER_VALUE', filterFunction: 'FILTER_FUNCTION' };
    const offset = 2;
    const limit = 3;
    const orderBy = 'INDEX';
    it('adds filters to local search attributes and to facet filter param', () => {
      const expectedFacetFilter = { field: fieldName, values: [facetFilter.filterValue], matchType: facetFilter.filterFunction };
      const actual = facetSearchVariables(fieldName, offset, limit, orderBy, facetFilter);
      expect(actual.searchParams.filters[actual.searchParams.filters.length - 1]).toEqual(expectedFacetFilter);
    });
    it('adds sort to facet filter values query', () => {
      const actual = facetSearchVariables(fieldName, offset, limit, orderBy, facetFilter);
      expect(actual.orderBy).toEqual({ field: orderBy });
    });
    it('adds offset and limit to facet filter values query', () => {
      const actual = facetSearchVariables(fieldName, offset, limit, orderBy, facetFilter);
      expect(actual.offset).toEqual(offset);
      expect(actual.limit).toEqual(limit);
    });
  });
});
