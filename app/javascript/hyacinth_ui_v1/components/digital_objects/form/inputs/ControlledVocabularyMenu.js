import React from 'react';
import PropTypes from 'prop-types';
import {
  Button, Dropdown, Form, Badge,
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
    page: 1,
  }

  componentDidMount() {
    const { page } = this.state;
    const { vocabulary: stringKey } = this.props;

    vocabulary(stringKey).terms().search(`page=${page}&per_page=${perPage}`).then((res) => {
      this.setState(produce((draft) => {
        draft.options = res.data.terms;
      }));
    });

    vocabulary(stringKey).get().then((res) => {
      this.setState(produce((draft) => {
        draft.vocabulary = res.data;
      }));
    });
  }

  onSelectHander = (event) => {
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

    vocabulary(stringKey).terms().search(`page=${page}&per_page=${perPage}&q=${q}`)
      .then((res) => {
        this.setState(produce((draft) => {
          draft.options = res.data.terms;
        }));
      });
  }

  render() {
    const {
      className,
      'aria-labelledby': labeledBy,
    } = this.props;

    const { vocabulary: vocab, search, options } = this.state;

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
              <Dropdown.Item
                as={Button}
                onClick={this.onSelectHander}
                key={o.uri}
                data-uri={o.uri}
              >
                {`${o.prefLabel} `}
                <Badge variant="primary">{o.authority}</Badge>
              </Dropdown.Item>
            ))
          }
        </ul>
      </div>
    );
  }
}

export default ControlledVocabularyMenu
