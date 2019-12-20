import React, { useState, useEffect } from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
  Button, Dropdown, Form, Badge, Collapse,
} from 'react-bootstrap';

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

  const onSelectHandler = (event) => {
    const { uri } = event.target.dataset;

    const term = options.find(o => o.uri === uri); // Find matching term in options.

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
          options.map(o => (
            <div className="px-3 py-1" key={o.uuid}>
              <Button variant="link" onClick={() => onCollapseHandler(o.uuid)} className="p-0">
                <FontAwesomeIcon icon="info-circle" />
              </Button>

              <Dropdown.Item
                className="px-1 mx-1"
                onClick={onSelectHandler}
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
                  <ul className="list-unstyled px-4" style={{ fontSize: '.8rem' }}>
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
          && <Button variant="link" onClick={onMoreHandler} className="float-right py-0">More...</Button>
      }
    </div>
  );
}

export default ControlledVocabularyOptions;
