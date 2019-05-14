import React from 'react';
import { Link } from 'react-router-dom';
import { Table, Button } from 'react-bootstrap';
import producer from 'immer';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { LinkContainer } from 'react-router-bootstrap';

import ProjectSubHeading from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';
import { Can } from '../../../util/ability_context';

export default class FieldSetIndex extends React.Component {
  state = {
    publishTargets: [],
  }

  componentDidMount() {
    hyacinthApi.get(`/projects/${this.props.match.params.projectStringKey}/publish_targets`)
      .then((res) => {
        this.setState(producer((draft) => { draft.publishTargets = res.data.publishTargets; }));
      });
  }

  render() {
    const { params: { projectStringKey } } = this.props.match

    let rows = <tr><td colSpan="4">No publish targets have been defined</td></tr>;

    if (this.state.publishTargets.length > 0) {
      rows = this.state.publishTargets.map(publishTarget => (
        <tr key={publishTarget.stringKey}>

          <td>
            <Can I="edit" of={{ subjectType: 'PublishTarget', project: { stringKey: projectStringKey } }} passThrough>
              {
                  can => (
                    can
                      ? <Link to={`/projects/${projectStringKey}/publish_targets/${publishTarget.stringKey}/edit`} href="#">{publishTarget.displayLabel}</Link>
                      : publishTarget.displayLabel
                  )
                }
            </Can>
          </td>
          <td>{publishTarget.stringKey}</td>
          <td>{publishTarget.publishUrl}</td>
          <td>{publishTarget.apiKey}</td>
        </tr>
      ));
    }

    return (
      <>
        <ProjectSubHeading>Publish Targets</ProjectSubHeading>

        <Table hover>
          <thead>
            <tr>
              <th>Display Label</th>
              <th>String Key</th>
              <th>Publish URL</th>
              <th>API Key</th>
            </tr>
          </thead>
          <tbody>
            {rows}
            <Can I="PublishTarget" of={{ subjectType: 'FieldSet', project: { stringKey: projectStringKey } }} >
              <tr>
                <td className="text-center" colSpan="4">
                  <LinkContainer to={`/projects/${projectStringKey}/publish_targets/new`}>
                    <Button size="sm" variant="link">
                      <FontAwesomeIcon icon="plus" />
                      {' '}
  Add New Publish Target
                    </Button>
                  </LinkContainer>
                </td>
              </tr>
            </Can>
          </tbody>
        </Table>
      </>
    );
  }
}
