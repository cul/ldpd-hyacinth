import FilterArrayParam from './filterArrayParam';

describe('filterArrayParam', () => {
  describe('FilterArrayParam', () => {
    it('encodes blank values as empty array', () => {
      expect(FilterArrayParam.encode()).toEqual([]);
      expect(FilterArrayParam.encode(null)).toEqual([]);
      expect(FilterArrayParam.encode([])).toEqual([]);
    });
  });
});
