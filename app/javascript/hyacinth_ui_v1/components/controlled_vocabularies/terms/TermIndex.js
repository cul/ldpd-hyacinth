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

const perPage = '10';
const defaultFilters = ['authority', 'uri', 'pref_label', 'alt_label', 'term_type'];

class TermIndex extends React.Component {
  state = {
    page: '1',
    search: '',
    filters: [],
    terms: [],
    totalRecords: 0,
  }

  componentDidMount() {
    const { match: { params: { stringKey } } } = this.props;
    const { page, search } = this.state;

    this.termSearch(page, search);
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

    this.termSearch(1, search);
  }

  termSearch = (page, search) => {
    const { match: { params: { stringKey } } } = this.props;

    vocabulary(stringKey).terms().search(`per_page=${perPage}&page=${page}&q=${search}`)
      .then((res) => {
        this.setState(produce((draft) => {
          draft.page = page;
          draft.search = search;
          draft.terms = res.data.terms;
          draft.totalRecords = res.data.totalRecords;
        }));
      });
  }

  onPageNumberClick = (newPage) => {
    const { search } = this.state;
    this.termSearch(newPage, search)
  }

  render() {
    const { match: { params: { stringKey } } } = this.props;
    const { terms, search, filters, page, totalRecords } = this.state;

    return (
      <>
        <Form onSubmit={this.onSearchHandler}>
          <Row className="mb-3">
            <TextInput
              sm={6}
              value={search}
              onChange={v => this.onChange('search', v)}
              placeholder="Search for terms..."
            />

            {
              filters.map(filter => (
                <Col sm="auto" style={{ alignSelf: 'center' }}>
                  <InputGroup>
                    <DropdownButton
                      as={InputGroup.Prepend}
                      variant="outline-secondary"
                      title={filter.label}
                      id="input-group-dropdown-1"
                      size="sm"
                    >
                      {
                        defaultFilters.map(f => (
                          <Dropdown.Item>{f.replace('_', ' ')}</Dropdown.Item>
                        ))
                      }
                    </DropdownButton>
                    <FormControl aria-describedby="basic-addon1" size="sm" />
                  </InputGroup>
                </Col>
              ))
            }

            <Col style={{ alignSelf: 'center' }}>
              <SearchButton onClick={this.onSearchHandler} />

              <Button variant="outline-secondary" size="sm" onClick={this.addFilter}>
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
          perPage={perPage}
          currentPage={page}
          totalItems={totalRecords}
          onPageNumberClick={this.onPageNumberClick}
        />
      </>
    );
  }
}

export default withRouter(TermIndex);
