// Item - Subclass
Hyacinth.DigitalObjectsApp.DigitalObject.Item = function(digital_object_data){
  Hyacinth.DigitalObjectsApp.DigitalObject.Base.call(this, digital_object_data); // call parent constructor
};
Hyacinth.extendClass(Hyacinth.DigitalObjectsApp.DigitalObject.Item, Hyacinth.DigitalObjectsApp.DigitalObject.Base); //Extend

Hyacinth.DigitalObjectsApp.DigitalObject.Item.prototype.hasImage = function (){
  return Hyacinth.imageServerUrl && this.ordered_child_digital_object_pids.length > 0;
};
