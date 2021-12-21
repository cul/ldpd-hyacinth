import React from 'react';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import { Badge, Card } from 'react-bootstrap';
import { startCase } from 'lodash';
import { setCurrentResultOffset } from '../../utils/digitalObjectSearchParams';
/*
  Display for list of Digital Objects. Have a flag to optionally display
  parents and projects. Parents and Projects are only displayed on the search
  page. Eventually, we may no longer be able to use a generalized componenet
  to display a list of digital objects.
*/

const DigitalObjectList = (props) => {
  const {
    digitalObjects, displayProjects, displayParentIds, offset, fromSearch,
  } = props;

  return (
    <>
      {
        digitalObjects.map((digitalObject, resultIndex) => (
          <Card key={digitalObject.id} className="mb-3 digital-object-result">
            <Card.Header className="px-2 py-1">
              <Link
                to={`/digital_objects/${digitalObject.id}`}
                onClick={() => { if (fromSearch) setCurrentResultOffset(offset + resultIndex); }}
              >
                {digitalObject.displayLabel}
              </Link>
            </Card.Header>
            <Card.Body className="p-2">
              <ul className="list-unstyled small">
                <li>
                  <strong>UID: </strong>
                  {digitalObject.id}
                </li>
                {
                  digitalObject.numberOfChildren > 0 && (
                    <li>
                      <strong>Children: </strong>
                      {digitalObject.numberOfChildren}
                    </li>
                  )
                }
                {
                  displayParentIds && digitalObject.parentIds.length > 0 && (
                    <li>
                      <strong>Parent(s): </strong>
                      {digitalObject.parentIds.map((id) => <a key={id} href={`digital_objects/${id}`}>{id}</a>)}
                    </li>
                  )
                }
              </ul>
              <Badge bg="secondary">{startCase(digitalObject.digitalObjectType)}</Badge>
              {
                displayProjects && digitalObject.projects.map((p) => (
                  <span key={`${digitalObject.id}_${p.stringKey}`}>
                    {' '}
                    <Badge bg="primary">{p.displayLabel}</Badge>
                  </span>
                ))
              }
            </Card.Body>
          </Card>
        ))
      }
    </>
  );
};

DigitalObjectList.defaultProps = {
  displayProjects: false,
  displayParentIds: false,
  offset: 0,
  fromSearch: false,
};

DigitalObjectList.propTypes = {
  digitalObjects: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.string.isRequired,
      digitalObjectType: PropTypes.string.isRequired,
      displayLabel: PropTypes.string.isRequired,
    }),
  ).isRequired,
  displayProjects: PropTypes.bool,
  displayParentIds: PropTypes.bool,
  offset: PropTypes.number,
  fromSearch: PropTypes.bool,
};

export default DigitalObjectList;
