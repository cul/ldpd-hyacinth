import React from 'react';

import Tab from '../shared/tabs/Tab';
import Tabs from '../shared/tabs/Tabs';
import TabBody from '../shared/tabs/TabBody';
import ContextualNavbar from '../shared/ContextualNavbar';

function ProjectInterface(props) {
  const { project, children } = props;

  if (!project) return (<></>);

  return (
    <>
      <ContextualNavbar
        title={`Project | ${project.displayLabel}`}
        rightHandLinks={[{ link: '/projects', label: 'Back to All Projects' }]}
      />

      <Tabs>
        <Tab to={`/projects/${project.stringKey}/core_data`} name="Core Data" />
        <Tab to={`/projects/${project.stringKey}/enabled_dynamic_fields/item`} name="Item Fields" />
        <Tab to={`/projects/${project.stringKey}/enabled_dynamic_fields/asset`} name="Asset Fields" />
        <Tab to={`/projects/${project.stringKey}/enabled_dynamic_fields/site`} name="Site Fields" />
        <Tab to={`/projects/${project.stringKey}/permissions`} name="Permissions" />
        <Tab to={`/projects/${project.stringKey}/publish_targets`} name="Publish Targets" />
        <Tab to={`/projects/${project.stringKey}/field_sets`} name="Field Sets" />
      </Tabs>

      <TabBody>
        {children}
      </TabBody>
    </>
  );
}

export default ProjectInterface;
