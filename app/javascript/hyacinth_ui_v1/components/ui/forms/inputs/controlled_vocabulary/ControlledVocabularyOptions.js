import React, { useState, useEffect } from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
  Button, Dropdown, Form, Badge, Collapse,
} from 'react-bootstrap';

import ControlledVocabularyOption from './ControlledVocabularyOption';
import { terms } from '../../../../../util/hyacinth_api';

const limit = '10';

function ControlledVocabularyOptions({ vocabulary, onChange }) {
  const [options, setOptions] = useState([]);
  const [search, setSearch] = useState('');
  const [offset, setOffset] = useState(0);
  const [totalResults, setTotalResults] = useState(0);
  const [infoExpandedFor, setInfoExpandedFor] = useState('');

  useEffect(() => {
    terms.search(vocabulary.stringKey, `offset=0&limit=${limit}`).then((res) => {
      setOptions(res.data.terms);
      setOffset(0);
      setTotalResults(res.data.totalRecords);
    });
  }, []);

  const onSelectHandler = (uri) => {
    const term = options.find(o => o.uri === uri);

    onChange(term);
  };

  const onSearchHandler = (event) => {
    const { target: { value } } = event;

    setSearch(event.target.value);

    const q = (value.length < 3) ? '' : value;

    terms.search(vocabulary.stringKey, `offset=0&limit=${limit}&q=${q}`)
      .then((res) => {
        setOptions(res.data.terms);
        setOffset(0);
        setTotalResults(res.data.totalRecords);
      });
  };

  const onCollapseHandler = (uuid) => {
    if (uuid === infoExpandedFor) {
      setInfoExpandedFor('');
    } else {
      setInfoExpandedFor(uuid);
    }
  };

  const onMoreHandler = () => {
    let queryString = `offset=${offset + limit}&limit=${limit}`;
    if (search && search.length >= 3) queryString = queryString.concat(`&q=${search}`);

    terms.search(vocabulary.stringKey, queryString).then((res) => {
      setOffset(offset + limit);
      setOptions(oldOptions => [...oldOptions, ...res.data.terms]);
    });
  };

  return (
    <div style={{ maxHeight: '350px', overflowY: 'auto' }}>
      <Form.Control
        size="sm"
        autoFocus
        className="mx-3 my-2 w-auto"
        placeholder="Type to search..."
        onChange={onSearchHandler}
        value={search}
      />

      <ul className="list-unstyled">
        {
          options.map(term => (
            <ControlledVocabularyOption
              term={term}
              onSelect={() => onSelectHandler(term.uri)}
              onCollapseToggle={() => onCollapseHandler(term.uuid)}
              expanded={infoExpandedFor === term.uuid}
            />
          ))
        }
      </ul>

      {
        totalResults > options.length
          && <Button variant="link" onClick={onMoreHandler} className="float-right py-0">More...</Button>
      }
    </div>
  );
}

export default ControlledVocabularyOptions;
