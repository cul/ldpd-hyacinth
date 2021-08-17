import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import { Badge, Card } from 'react-bootstrap';
import { startCase } from 'lodash';
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd';
/*
  Display for list of Digital Objects. Have a flag to optionally display
  parents and projects. Parents and Projects are only displayed on the search
  page. Eventually, we may no longer be able to use a generalized componenet
  to display a list of digital objects.
*/

const storeSearchValues = (
  orderBy, totalCount, perPage, offset, pageNumber, q, filters, path, pageResultIndex,
) => {
  if (path === '/digital_objects') {
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

    const resultIndex = ((pageNumber - 1) * perPage) + pageResultIndex + 1;
    const newOffset = resultIndex < 3 ? 0 : resultIndex - 2;
    window.sessionStorage.setItem('offset', newOffset);
    window.sessionStorage.setItem('resultIndex', resultIndex);
    window.sessionStorage.setItem('totalCount', totalCount);
  } else {
    window.sessionStorage.setItem('searchQueryParams', '');
    window.sessionStorage.setItem('offset', '');
    window.sessionStorage.setItem('resultIndex', '');
    window.sessionStorage.setItem('totalCount', '');
  }
};

const DigitalObjectList = (props) => {
  const {
    digitalObjects, displayProjects, displayParentIds, orderBy, totalCount,
    limit, offset, pageNumber, searchParams, path, disableDrag,
  } = props;

  const [currentObjectList, setCurrentObjectList] = useState(digitalObjects);

  const onDragEnd = (result) => {
    const { destination, source } = result;

    if (!destination) {
      return;
    }

    // no changes
    if (
      destination.droppableId === source.droppableId
      && destination.index === source.index
    ) {
      return;
    }

    const newList = Array.from(currentObjectList);
    // insert dragged element to new location
    newList.splice(destination.index, 0, newList.splice(source.index, 1)[0]);
    setCurrentObjectList(newList);
  };


  return (
    <>
      <DragDropContext onDragEnd={onDragEnd}>

        <Droppable droppableId="droppable-1">
          {DroppableProvided => (
            <div
              ref={DroppableProvided.innerRef}
              {...DroppableProvided.droppableProps}
            >
              {
        currentObjectList.map((digitalObject, resultIndex) => (
          <Draggable
            draggableId={
            digitalObject.id}
            index={resultIndex}
            key={digitalObject.id}
            isDragDisabled={disableDrag
            }
          >
            {provided => (
              <Card
                key={digitalObject.id}
                className="mb-3"
                {...provided.draggableProps}
                {...provided.dragHandleProps}
                ref={provided.innerRef}
              >
                <Card.Header>
                  <Link
                    to={`/digital_objects/${digitalObject.id}`}
                    onClick={() => searchParams && storeSearchValues(
                      orderBy, totalCount, limit, offset,
                      pageNumber, searchParams.query, searchParams.filters, path, resultIndex,
                    )}
                  >
                    {digitalObject.title}
                  </Link>
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
              <Badge bg="secondary">{startCase(digitalObject.digitalObjectType)}</Badge>
              {
                displayProjects && digitalObject.projects.map(p => (
                  <span key={`${digitalObject.id}_${p.stringKey}`}>
                    {' '}
                    <Badge bg="primary">{p.displayLabel}</Badge>
                  </span>
                ))
              }
                </Card.Body>
              </Card>
            )}
          </Draggable>

        ))
      }

              {DroppableProvided.placeholder}
            </div>

          )}
        </Droppable>
      </DragDropContext>

    </>
  );
};


DigitalObjectList.defaultProps = {
  displayProjects: false,
  displayParentIds: false,
  orderBy: '',
  totalCount: 0,
  limit: 0,
  offset: 0,
  pageNumber: 0,
  searchParams: null,
  path: '',
  disableDrag: true,
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
  path: PropTypes.string,
  disableDrag: PropTypes.bool,
};

export default DigitalObjectList;
