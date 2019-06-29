import React from 'react';
import PropTypes from 'prop-types';
import {
  Button, Dropdown, Form, Badge, Collapse,
} from 'react-bootstrap';
import produce from 'immer';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import { vocabulary } from '../../../../util/hyacinth_api';

const perPage = '10';

class ControlledVocabularyMenu extends React.Component {
  state = {
    vocabulary: {
      stringKey: '',
      label: '',
    },
    options: [],
    search: '',
    lastPage: 0,
    totalResults: 0,
    infoExpandedFor: '',
  }

  componentDidMount() {
    const { vocabulary: stringKey } = this.props;

    vocabulary(stringKey).terms().search(`page=1&per_page=${perPage}`).then((res) => {
      this.setState(produce((draft) => {
        draft.options = res.data.terms;
        draft.lastPage = 1;
        draft.totalResults = res.data.totalRecords;
      }));
    });

    vocabulary(stringKey).get().then((res) => {
      this.setState(produce((draft) => {
        draft.vocabulary = res.data;
      }));
    });
  }

  onSelectHandler = (event) => {
    const { onChange } = this.props;
    const { options } = this.state;
    const { uri } = event.target.dataset;

    const term = options.find(o => o.uri === uri); // Find matching term in options.

    onChange(term);
  }

  onSearchHandler = (event) => {
    const { target: { value } } = event;
    const { vocabulary: { stringKey }, page } = this.state;

    this.setState({ search: event.target.value });

    const q = (value.length < 3) ? '' : value;

    vocabulary(stringKey).terms().search(`page=1&per_page=${perPage}&q=${q}`)
      .then((res) => {
        this.setState(produce((draft) => {
          draft.options = res.data.terms;
          draft.lastPage = 1;
          draft.totalResults = res.data.totalRecords;
        }));
      });
  }

  onCollapseHandler = (uuid) => {
    const { infoExpandedFor } = this.state;

    if (uuid === infoExpandedFor) {
      this.setState(produce((draft) => {
        draft.infoExpandedFor = '';
      }));
    } else {
      this.setState(produce((draft) => {
        draft.infoExpandedFor = uuid;
      }));
    }
  }

  onMoreHandler = () => {
    const { lastPage, search } = this.state;
    const { vocabulary: stringKey } = this.props;

    let queryString = `page=${lastPage + 1}&per_page=${perPage}`;
    if (search && search.length >= 3) queryString = queryString.concat(`&q=${search}`)

    vocabulary(stringKey).terms().search(queryString).then((res) => {
      this.setState(produce((draft) => {
        draft.options = draft.options.concat(res.data.terms);
        draft.lastPage = lastPage + 1;
      }));
    });
  }

  getTerms(page) {

  }

  render() {
    const {
      className,
      'aria-labelledby': labeledBy,
    } = this.props;

    const { infoExpandedFor, vocabulary: vocab, search, options, totalResults } = this.state;

    return (
      <div style={{ minWidth: '25rem' }} className={className} aria-labelledby={labeledBy}>
        <Dropdown.Header>
          {`${vocab.label} Controlled Vocabulary`}
          <span className="float-right">
            <FontAwesomeIcon icon="plus" />
            {' New Term'}
          </span>
        </Dropdown.Header>
        <Dropdown.Divider />
        <Form.Control
          size="sm"
          autoFocus
          className="mx-3 my-2 w-auto"
          placeholder="Type to search..."
          onChange={this.onSearchHandler}
          value={search}
        />

        <ul className="list-unstyled">
          {
            options.map(o => (
              <div className="px-3 py-1" key={o.uuid}>
                <Button variant="link" onClick={() => this.onCollapseHandler(o.uuid)} className="p-0">
                  <FontAwesomeIcon icon="info-circle" />
                </Button>

                <Dropdown.Item
                  className="px-1 mx-1"
                  onClick={this.onSelectHandler}
                  key={o.uri}
                  data-uri={o.uri}
                  style={{ display: 'inline' }}
                >
                  {`${o.prefLabel} `}
                </Dropdown.Item>

                {
                  o.termType === 'temporary'
                    ? <Badge variant="danger">Temporary Term</Badge>
                    : <a className="badge badge-primary" href={o.uri} target="_blank" rel="noopener noreferrer">{o.authority}</a>
                }
                <Collapse in={infoExpandedFor === o.uuid}>
                  <div>
                    <ul className="list-unstyled px-4" style={{ fontSize: '.8rem'}}>
                      <li>
                        <strong>URI:</strong> {o.uri}
                        <a className="px-1" href={o.uri} target="_blank" rel="noopener noreferrer">
                          <FontAwesomeIcon icon="external-link-square-alt" />
                        </a>
                      </li>
                      <li>
                        <strong>Type:</strong> {o.termType}
                      </li>
                      {
                        o.termType !== 'temporary' && (
                          <li>
                            <strong>Authority:</strong> {o.authority}
                          </li>
                        )
                      }
                    </ul>
                  </div>
                </Collapse>
              </div>
            ))
          }
        </ul>
        {
          totalResults > options.length
            && <Button variant="link" onClick={this.onMoreHandler}>More...</Button>
        }
      </div>
    );
  }
}

export default ControlledVocabularyMenu
