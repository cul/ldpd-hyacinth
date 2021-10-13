import {
  backToSearchPath,
  decodedQueryParamstoSearchParams,
  defaultQueryParams,
  encodeSessionSearchParams,
  locationSearchToSearchParams,
  searchParamsToLocationSearch,
} from './digitalObjectSearchParams';

describe('digitalObjectSearchParams', () => {
  const singleDecodedFilterValue = { field: 'ExpectedField', values: ['ExpectedValue'] };
  const singleEncodedFilterValue = 'filters=ExpectedField%3A%3AExpectedValue';
  describe('defaultQueryParams', () => {
    it('sets expected defaults', () => {
      const defaults = defaultQueryParams();
      expect(defaults.q).toBeUndefined();
      expect(defaults.filters).toEqual([]);
      expect(defaults.searchType).toEqual('KEYWORD');
      expect(defaults.pageNumber).toEqual(1);
      expect(defaults.perPage).toEqual(20);
      expect(defaults.orderBy).toEqual('TITLE ASC');
    });
  });
  describe('backToSearchPath', () => {
    it('returns null when there is no stored session search', () => {
      window.sessionStorage.removeItem('searchQueryParams');
      expect(backToSearchPath()).toBeNull();
    });
    it('returns null when there is blank stored session search', () => {
      window.sessionStorage.setItem('searchQueryParams', '');
      expect(backToSearchPath()).toBeNull();
    });
    it('returns null when there is empty stored session search', () => {
      window.sessionStorage.setItem('searchQueryParams', '{}');
      expect(backToSearchPath()).toBeNull();
    });
    it('returns a query string when there is a stored session search', () => {
      encodeSessionSearchParams({ searchTerms: 'success' });
      expect(backToSearchPath()).toMatch('q=success');
    });
    it('does not set empty params when there is no default', () => {
      encodeSessionSearchParams({ orderBy: 'TITLE DESC' });
      const path = backToSearchPath();
      expect(path).not.toMatch('q=');
      expect(path).not.toMatch('filters=');
      expect(path).toMatch('orderBy=TITLE%20DESC');
    });
  });

  describe('searchParamsToLocationSearch', () => {
    it('encodes filters', () => {
      const searchParams = { filters: [singleDecodedFilterValue] };
      expect(searchParamsToLocationSearch(searchParams)).toMatch(singleEncodedFilterValue);
    });
    it('encodes searchTerms', () => {
      const searchParams = { searchTerms: 'success' };
      expect(searchParamsToLocationSearch(searchParams)).toMatch('q=success');
    });
    it('sets default query params', () => {
      const path = searchParamsToLocationSearch({});
      expect(path).toMatch('orderBy=TITLE%20ASC');
    });
  });

  describe('locationSearchToSearchParams', () => {
    it('decodes filters as an array', () => {
      const location = { search: singleEncodedFilterValue };
      const searchParams = locationSearchToSearchParams(location);
      expect(searchParams.filters).toEqual([singleDecodedFilterValue]);
    });
    it('sets default values', () => {
      const location = { search: '' };
      const searchParams = locationSearchToSearchParams(location);
      expect(searchParams.orderBy).toEqual('TITLE ASC');
    });
  });

  describe('decodedQueryParamstoSearchParams', () => {
    it('calculates offset from pageNumber', () => {
      const searchParams = decodedQueryParamstoSearchParams({ ...defaultQueryParams(), pageNumber: 3 });
      expect(searchParams.offset).toEqual(40);
    });
    it('renames searchTerms to q', () => {
      const expected = 'success';
      const searchParams = decodedQueryParamstoSearchParams({ q: expected });
      expect(searchParams.searchTerms).toEqual(expected);
    });
  });
});
