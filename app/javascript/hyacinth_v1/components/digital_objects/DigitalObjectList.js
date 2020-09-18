import React from 'react';
import PropTypes from 'prop-types';
import { Badge, Card } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import { startCase } from 'lodash';
/*
  Display for list of Digital Objects. Have a flag to optionally display
  parents and projects. Parents and Projects are only displayed on the search
  page. Eventually, we may no longer be able to use a generalized componenet
  to display a list of digital objects.
*/


const storeSearchQueryParams = (orderBy, totalCount, perPage, offset, pageNumber, q, filters) => {
  if (q || filters.length > 0) {
    window.sessionStorage.setItem('searchQueryParams',
      JSON.stringify(
        {
          orderBy,
          totalCount,
          perPage,
          offset,
          pageNumber,
          q,
          filters,
        },
      ));
  } else {
    window.sessionStorage.setItem('searchQueryParams', '');
  }
};


const DigitalObjectList = (props) => {
  const {
    digitalObjects, displayProjects, displayParentIds, orderBy, totalCount,
    limit, offset, pageNumber, searchParams,
  } = props;

  return (
    <>
      {
        digitalObjects.map(digitalObject => (
          <Card key={digitalObject.id} className="mb-3">
            <Card.Header>
              <LinkContainer
                to={`/digital_objects/${digitalObject.id}`}
                onClick={() => storeSearchQueryParams(
                  orderBy, totalCount, limit, offset,
                  pageNumber, searchParams.query, searchParams.filters,
                )
                }
              >
                <a>{digitalObject.title}</a>
              </LinkContainer>
            </Card.Header>
            <Card.Body>
              <ul className="list-unstyled small">
                <li>
                  <strong>ID: </strong>
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
                      { digitalObject.parentIds.map(id => <a key={id} href={`digital_objects/${id}`}>{id}</a>) }
                    </li>
                  )
                }
              </ul>
              <Badge variant="secondary">{startCase(digitalObject.digitalObjectType)}</Badge>
              {
                displayProjects && digitalObject.projects.map(p => (
                  <span key={`${digitalObject.id}_${p.stringKey}`}>
                    {' '}
                    <Badge variant="primary">{p.displayLabel}</Badge>
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
  orderBy: false,
  totalCount: false,
  limit: false,
  offset: false,
  pageNumber: false,
  searchParams: false,
};

DigitalObjectList.propTypes = {
  digitalObjects: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.string.isRequired,
      digitalObjectType: PropTypes.string.isRequired,
      title: PropTypes.string.isRequired,
    }),
  ).isRequired,
  displayProjects: PropTypes.bool,
  displayParentIds: PropTypes.bool,
  orderBy: PropTypes.string,
  totalCount: PropTypes.number,
  limit: PropTypes.number,
  offset: PropTypes.number,
  pageNumber: PropTypes.number,
  searchParams: PropTypes.shape({
    query: PropTypes.string,
    filters: PropTypes.arrayOf(
      PropTypes.shape({
        field: PropTypes.string,
        value: PropTypes.string,
      }),
    ),
  }),
};

export default DigitalObjectList;
