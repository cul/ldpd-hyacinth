import React from 'react';
import { Button, Collapse } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

class DigitalObjectSummary extends React.Component {
  state = {
    moreDetailsOpen: false,
  }

  render() {
    const {
      data: {
        digitalObjectType,
        projects,
        pid,
        uid,
        doi,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        firstPublishedAt
      }
    } = this.props;
    const { moreDetailsOpen } = this.state;

    return (
      <>
        <dl className="row mb-0">
          <dt className="col-sm-3">Project(s)</dt>
          <dd className="col-sm-9">
            { projects && projects.map(p => <span>{p.displayLabel}</span>) }
          </dd>

          <dt className="col-sm-3">UID</dt>
          <dd className="col-sm-9">{uid || '- Assigned After Save -'}</dd>

          <dt className="col-sm-3">DOI</dt>
          <dd className="col-sm-9">{doi || '- Assigned After Publish -'}</dd>
        </dl>
        {
          uid && (
            <>
              <dl className="row mb-0">
                <dt className="col-sm-3">Child Objects</dt>
                <dd className="col-sm-9"></dd>

                <dt className="col-sm-3">View As</dt>
                <dd className="col-sm-9">
                  <a href={`/api/v1/digital_objects/${uid}.json`} target="_blank" rel="noopener noreferrer">JSON</a>
                </dd>
              </dl>

              <Button
                size="sm"
                variant="link"
                className="p-0"
                onClick={() => this.setState({ moreDetailsOpen: !moreDetailsOpen })}
                aria-controls="collapse-more-details"
                aria-expanded={moreDetailsOpen}
              >
                {moreDetailsOpen ? 'Less Details' : 'More Details'}
                {' '}
                <FontAwesomeIcon icon={moreDetailsOpen ? 'angle-double-up' : 'angle-double-down'} />
              </Button>

              <Collapse in={moreDetailsOpen}>
                <dl className="row mb-0">
                  <dt className="col-sm-3">Created By</dt>
                  <dd className="col-sm-9">{createdBy || '-- Assigned After Save --'}</dd>
                  <dt className="col-sm-3">Created On</dt>
                  <dd className="col-sm-9">{createdAt || '-- Assigned After Save --'}</dd>
                  <dt className="col-sm-3">Last Modified By</dt>
                  <dd className="col-sm-9">{updatedBy || '-- Assigned After Save --'}</dd>
                  <dt className="col-sm-3">Last Modified On</dt>
                  <dd className="col-sm-9">{updatedAt || '-- Assigned After Save --'}</dd>
                  <dt className="col-sm-3">First Published At</dt>
                  <dd className="col-sm-9">{firstPublishedAt || '-- Assigned After Publish --'}</dd>
                </dl>
              </Collapse>
            </>
          )
        }
      </>
    );
  }
}

export default DigitalObjectSummary;
