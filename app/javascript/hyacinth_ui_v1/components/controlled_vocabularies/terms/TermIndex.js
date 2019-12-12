import React from 'react';
import { Link, withRouter } from 'react-router-dom';
import {
  Form, Button, Row, Col, Table, DropdownButton, InputGroup, Dropdown, FormControl,
} from 'react-bootstrap';
import produce from 'immer';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { upperCase } from 'lodash';

import hyacinthApi, { vocabulary } from '../../../util/hyacinth_api';
import TextInput from '../../ui/forms/inputs/TextInput';
import SearchButton from '../../ui/buttons/SearchButton';
import PaginationBar from '../../ui/PaginationBar';
import SelectInput from '../../ui/forms/inputs/SelectInput';

const limit = 10;
const defaultFilters = ['authority', 'uri', 'pref_label', 'alt_labels', 'term_type'];

class TermIndex extends React.Component {
  state = {
    offset: 0,
    search: '',
    filters: [],
    terms: [],
    totalRecords: 0,
  }

  componentDidMount() {
    const { match: { params: { stringKey } } } = this.props;
    const { offset, search } = this.state;

    this.termSearch(offset, search);
  }

  onChange = (name, value) => {
    this.setState(produce((draft) => {
      draft[name] = value;
    }));
  }

  addFilter = () => {
    this.setState(produce((draft) => {
      draft.filters.push({ label: 'authority', value: '' });
    }));
  }

  onSearchHandler = (event) => {
    event.preventDefault();
    event.stopPropagation();

    const { match: { params: { stringKey } } } = this.props;
    const { search } = this.state;

    // TODO: Do not search if search term is under three characters AND there are no filters.

    this.termSearch(0, search);
  }

  termSearch = (offset, search) => {
    const { match: { params: { stringKey } } } = this.props;

    vocabulary(stringKey).terms().search(`limit=${limit}&offset=${offset}&q=${search}`)
      .then((res) => {
        console.log(res)
        this.setState(produce((draft) => {
          draft.offset = offset;
          draft.search = search;
          draft.terms = res.data.terms;
          draft.totalRecords = res.data.totalRecords;
        }));
      });
  }

  onPageNumberClick = (newPage) => {
    const { search } = this.state;
    this.termSearch(limit * (newPage - 1), search)
  }

  render() {
    const { match: { params: { stringKey } } } = this.props;
    const { terms, search, filters, offset, totalRecords } = this.state;

    return (
      <>
        <Form className="term-search-form" onSubmit={this.onSearchHandler}>
          <Row className="mb-3">
            <TextInput
              sm={8}
              value={search}
              onChange={v => this.onChange('search', v)}
              placeholder="Search for terms..."
            />
            <SearchButton onClick={this.onSearchHandler} />
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
              <Button variant="outline-secondary" size="sm" onClick={this.addFilter}>
                <FontAwesomeIcon icon="plus" />
                {' Add Filter'}
              </Button>
            </Col>
          </Row>

            {/* <Col sm={3} style={{ alignSelf: 'center' }}>
              <SearchButton onClick={this.onSearchHandler} />

              <Button variant="outline-secondary" size="sm" onClick={this.addFilter}>
                <FontAwesomeIcon icon="plus" />
                {' Add Filter'}
              </Button>
            </Col> */}
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
                  <tr key={term.uid}>
                    <td><Link to={`/controlled_vocabularies/${stringKey}/terms/${encodeURIComponent(term.uri)}/edit`}>{term.prefLabel}</Link></td>
                    <td>{term.termType}</td>
                    <td>{term.authority}</td>
                    <td>{term.uri}</td>
                  </tr>
                ))
              ) : <tr><td colspan={4}>No Results</td></tr>
            }
          </tbody>
        </Table>

        <PaginationBar
          limit={limit}
          offset={offset}
          totalItems={totalRecords}
          onPageNumberClick={this.onPageNumberClick}
        />
      </>
    );
  }
}

export default withRouter(TermIndex);
