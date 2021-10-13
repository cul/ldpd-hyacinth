import * as qs from 'query-string';
import {
  NumberParam, StringParam, withDefault, decodeQueryParams, encodeQueryParams,
} from 'use-query-params';
import FilterArrayParam from './filterArrayParam';

export const queryParamsConfig = {
  q: StringParam,
  searchType: withDefault(StringParam, 'KEYWORD'),
  filters: withDefault(FilterArrayParam, []),
  pageNumber: withDefault(NumberParam, 1),
  perPage: withDefault(NumberParam, 20),
  orderBy: withDefault(StringParam, 'TITLE ASC'),
};

export const defaultQueryParams = () => Reflect.ownKeys(queryParamsConfig).reduce((acc, key) => {
  acc[key] = queryParamsConfig[key].decode();
  return acc;
}, {});

const searchParamsToDecodedQueryParams = (searchParams) => {
  const queryParams = { ...searchParams };
  // Delete search parameters that shouldn't appear in a user-facing search url
  delete queryParams.totalCount;
  // URLs have q param, components have searchTerms
  if (queryParams.searchTerms) {
    queryParams.q = queryParams.searchTerms;
  }
  delete queryParams.searchTerms;
  // URL locations have pageNumber and perPage, searchParams have offset and limit
  queryParams.perPage = queryParams.limit;
  if (queryParams.offset) {
    queryParams.pageNumber = (queryParams.offset / queryParams.limit) + 1;
  }
  delete queryParams.offset;
  delete queryParams.limit;
  return { ...defaultQueryParams(), ...queryParams };
};

export const searchParamsToLocationSearch = (searchParams) => qs.stringify(
  encodeQueryParams(
    queryParamsConfig,
    searchParamsToDecodedQueryParams(searchParams),
  ),
);

export const decodedQueryParamstoSearchParams = (decodedValues) => {
  // URL locations have q param, searchParams have searchTerms
  if (decodedValues.q) {
    decodedValues.searchTerms = decodedValues.q;
    delete decodedValues.q;
  }
  // URL locations have pageNumber and perPage, searchParams have offset and limit
  const { perPage, pageNumber } = decodedValues;

  decodedValues.offset = pageNumber ? (pageNumber - 1) * perPage : 0;
  delete decodedValues.pageNumber;
  decodedValues.limit = perPage;
  delete decodedValues.perPage;
  return decodedValues;
};

export const locationSearchToSearchParams = (location) => {
  const encodedParamValues = qs.parse(location.search);
  return decodedQueryParamstoSearchParams(decodeQueryParams(queryParamsConfig, encodedParamValues));
};

export const encodeSessionSearchParams = (searchParams) => {
  const {
    orderBy, totalCount, limit, offset, pageNumber, searchTerms, searchType, filters,
  } = searchParams;
  window.sessionStorage.setItem(
    'searchQueryParams',
    JSON.stringify({
      orderBy,
      totalCount,
      limit,
      offset,
      pageNumber,
      searchTerms,
      searchType,
      filters,
    }),
  );
};

const isEmpty = (object) => Object.keys(object).length === 0;

export const decodeSessionSearchParams = () => {
  const sessionStoredValue = window.sessionStorage.getItem('searchQueryParams');
  return sessionStoredValue ? JSON.parse(sessionStoredValue) : {};
};

export const backToSearchPath = () => {
  const latestStoredSearch = decodeSessionSearchParams();
  if (!latestStoredSearch || isEmpty(latestStoredSearch)) return null;
  const search = searchParamsToLocationSearch(latestStoredSearch);
  return `/digital_objects?${search}`;
};

export const currentResultOffset = () => Number(window.sessionStorage.getItem('resultOffset'));

export const setCurrentResultOffset = (currentIndex) => {
  window.sessionStorage.setItem('resultOffset', currentIndex);
};
