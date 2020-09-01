import FilterArrayParam from './filterArrayParam';
import * as qs from 'query-string';
import {
  NumberParam, StringParam, withDefault, encodeQueryParams
} from 'use-query-params';

export const queryParamsConfig = {
  q: StringParam,
  filters: withDefault(FilterArrayParam, []),
  pageNumber: withDefault(NumberParam, 1),
  perPage: withDefault(NumberParam, 20),
  orderBy: withDefault(StringParam, 'TITLE ASC'),
};


 export const redirectToSearch = (history, queryParams) => {
     const search = qs.stringify(encodeQueryParams(queryParamsConfig, queryParams));
     history.push(`/digital_objects?${search}`);
 }
