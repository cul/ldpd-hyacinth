import { deepCamelCase, deepSnakeCase } from './keyTransformer';

describe('keyTransformer', () => {
  const snakeCaseExample = {
    depth_one_first: 'pumpkin pie',
    depth_one_second: {
      depth_two_first: 'apple pie',
      depth_two_second: 'blueberry pie',
    },
    depth_one_third: {
      subkey_two: {
        depth_three_first: 'banana cream pie',
        depth_three_second: 'chicken pot pie',
      },
    },
  };
  const camelCaseExample = {
    depthOneFirst: 'pumpkin pie',
    depthOneSecond: {
      depthTwoFirst: 'apple pie',
      depthTwoSecond: 'blueberry pie',
    },
    depthOneThird: {
      subkeyTwo: {
        depthThreeFirst: 'banana cream pie',
        depthThreeSecond: 'chicken pot pie',
      },
    },
  };

  describe('deepCamelCase', () => {
    it('returns a recursively camelCase key-transformed copy of the given object', () => {
      expect(deepCamelCase(snakeCaseExample)).toEqual(camelCaseExample);
    });
  });

  describe('deepSnakeCase', () => {
    it('returns a recursively snake_case key-transformed copy of the given object', () => {
      expect(deepSnakeCase(camelCaseExample)).toEqual(snakeCaseExample);
    });
  });
});
