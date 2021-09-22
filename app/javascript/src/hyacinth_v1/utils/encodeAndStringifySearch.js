import * as qs from 'query-string';
import {
  NumberParam, StringParam, withDefault, encodeQueryParams,
} from 'use-query-params';
import FilterArrayParam from './filterArrayParam';

export const queryParamsConfig = {
  q: StringParam,
  searchType: withDefault(StringParam, 'KEYWORD'),
  filters: withDefault(FilterArrayParam, []),
  pageNumber: withDefault(NumberParam, 1),
  perPage: withDefault(NumberParam, 20),
  orderBy: withDefault(StringParam, 'TITLE ASC'),
  totalCount: withDefault(NumberParam, 0),
  offset: withDefault(NumberParam, 1),
};

// eslint-disable-next-line max-len
export const encodeAndStringifySearch = (queryParams) => qs.stringify(encodeQueryParams(queryParamsConfig, queryParams));
