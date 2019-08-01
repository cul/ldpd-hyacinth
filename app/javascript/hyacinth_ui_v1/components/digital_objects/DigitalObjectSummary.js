import React from 'react';

class DigitalObjectSummary extends React.PureComponent {
  render() {
    const {
      data: {
        projects,
        pid,
        uid,
        doi,
      }
    } = this.props;

    return (
      <div className="m-3">
        <dl className="row mb-0">
          <dt className="col-sm-3">Project(s)</dt>
          <dd className="col-sm-9">
            { projects && projects.map(p => <span key={p.stringKey}>{p.displayLabel}</span>) }
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
                <dd className="col-sm-9">-- None --</dd>

                <dt className="col-sm-3">View As</dt>
                <dd className="col-sm-9">
                  <a href={`/api/v1/digital_objects/${uid}.json`} target="_blank" rel="noopener noreferrer">JSON</a>
                </dd>
              </dl>
            </>
          )
        }
      </div>
    );
  }
}

export default DigitalObjectSummary;
