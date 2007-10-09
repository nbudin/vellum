CREATE TABLE `attr_value_metadatas` (
  `id` int(11) NOT NULL auto_increment,
  `attr_id` int(11) default NULL,
  `structure_id` int(11) default NULL,
  `value_id` int(11) default NULL,
  `value_type` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `attrs` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `template_id` int(11) default NULL,
  `attr_configuration_id` int(11) default NULL,
  `attr_configuration_type` varchar(255) default NULL,
  `position` int(11) default NULL,
  `required` tinyint(1) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `document_versions` (
  `id` int(11) NOT NULL auto_increment,
  `document_id` int(11) default NULL,
  `version` int(11) default NULL,
  `title` text,
  `content` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `template_id` int(11) default NULL,
  `project_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `documents` (
  `id` int(11) NOT NULL auto_increment,
  `title` text,
  `content` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `template_id` int(11) default NULL,
  `version` int(11) default NULL,
  `project_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `projects` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `template_schema_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `relationship_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `left_description` varchar(255) default NULL,
  `right_description` varchar(255) default NULL,
  `left_template_id` int(11) default NULL,
  `right_template_id` int(11) default NULL,
  `template_schema_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `relationships` (
  `id` int(11) NOT NULL auto_increment,
  `relationship_type_id` int(11) default NULL,
  `left_id` int(11) default NULL,
  `right_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `structures` (
  `id` int(11) NOT NULL auto_increment,
  `template_id` int(11) default NULL,
  `project_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `template_schemas` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `templates` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `parent_id` int(11) default NULL,
  `template_schema_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `text_fields` (
  `id` int(11) NOT NULL auto_increment,
  `default` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `text_values` (
  `id` int(11) NOT NULL auto_increment,
  `value` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO schema_info (version) VALUES (13)