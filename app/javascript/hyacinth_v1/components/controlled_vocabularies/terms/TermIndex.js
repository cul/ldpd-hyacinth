import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import {
  Form, Button, Row, Col, Table, DropdownButton, InputGroup, Dropdown, FormControl,
} from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { upperCase } from 'lodash';
import { useQuery } from '@apollo/react-hooks';

import TextInput from '../../shared/forms/inputs/TextInput';
import SearchButton from '../../shared/buttons/SearchButton';
import PaginationBar from '../../shared/PaginationBar';
import SelectInput from '../../shared/forms/inputs/SelectInput';
import { getTermsQuery } from '../../../graphql/terms';
import GraphQLErrors from '../../shared/GraphQLErrors';

const limit = 10;
const defaultFilters = ['authority', 'uri', 'pref_label', 'alt_labels', 'term_type'];

function TermIndex(props) {
  const { vocabularyStringKey } = props;

  const [offset, setOffset] = useState(0);
  const [query, setQuery] = useState('');
  const [totalTerms, setTotalTerms] = useState(0);
  const [filters, setFilters] = useState([]);

  const {
    loading, error, data, refetch,
  } = useQuery(getTermsQuery, {
    variables: {
      vocabularyStringKey, limit, offset, searchParams: { query },
    },
    onCompleted: res => setTotalTerms(res.vocabulary.terms.totalCount),
  });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const onSearchHandler = (event) => {
    // event.preventDefault();
    // event.stopPropagation();

    // TODO: Do not search if search term is under three characters AND there are no filters.

    refetch();
  };

  const onPageNumberClick = (newOffset) => {
    setOffset(newOffset);
    refetch();
  };

  const addFilter = () => {};

  const { vocabulary: { terms: { nodes: terms } } } = data;

  return (
    <>
      <Form className="term-search-form">
        <Row className="mb-3">
          <TextInput
            sm={8}
            value={query}
            onChange={v => setQuery(v)}
            placeholder="Search for terms..."
          />
          <SearchButton onClick={onSearchHandler} />
        </Row>
        <Row>
          {
            filters.map(filter => (
              <Col sm={8} style={{ alignSelf: 'center' }}>
                <Row>
                  <SelectInput
                    sm={4}
                    className="pr-1"
                    value={filter[0]}
                    options={defaultFilters.map(f => ({ value: f, label: f }))}
                  />
                  <TextInput
                    sm={8}
                    className="pl-1"
                    value={filter[1]}
                  />
                </Row>
              </Col>
            ))
          }
          <Col sm={2}>
            <Button variant="outline-secondary" size="sm" onClick={addFilter}>
              <FontAwesomeIcon icon="plus" />
              {' Add Filter'}
            </Button>
          </Col>
        </Row>
      </Form>

      <Table hover>
        <thead>
          <tr>
            <th>Pref Label</th>
            <th>Type</th>
            <th>Authority</th>
            <th>URI</th>
          </tr>
        </thead>
        <tbody>
          {
            terms.length > 0 ? (
              terms.map(term => (
                <tr key={term.id}>
                  <td><Link to={`/controlled_vocabularies/${vocabularyStringKey}/terms/${encodeURIComponent(term.uri)}`}>{term.prefLabel}</Link></td>
                  <td>{term.termType}</td>
                  <td>{term.authority}</td>
                  <td>{term.uri}</td>
                </tr>
              ))
            ) : <tr><td colSpan={4}>No Results</td></tr>
          }
        </tbody>
      </Table>

      <PaginationBar
        limit={limit}
        offset={offset}
        totalItems={totalTerms}
        onClick={onPageNumberClick}
      />
    </>
  );
}

TermIndex.propTypes = {
  vocabularyStringKey: PropTypes.string.isRequired,
};

export default TermIndex;
