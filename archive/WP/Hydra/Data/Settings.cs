﻿using System.Data.Linq;
using System.Data.Linq.Mapping;

namespace Hydra.Data
{
    class Settings:DataContext
    {
        public Settings(string connectionString)
            : base(connectionString)
      {
      }

        public Table<SettingsTable> SettingsTable
        {
            get { return GetTable<SettingsTable>(); }
        }

    }


    [Table(Name = "SettingsTable")]
    class SettingsTable
    {

        [Column(IsPrimaryKey = true, IsDbGenerated = false,CanBeNull = false)]
        public int Id { get; set; }

        [Column(CanBeNull = false)]
        public string Filtering { get; set; }

        [Column(CanBeNull = false)]
        public string Associations { get; set; }

        [Column(CanBeNull = false)]
        public string CacheDate { get; set; }

        [Column(CanBeNull = true)]
        public string AccessKey { get; set; }

        [Column(CanBeNull = true)]
        public string FbUserId { get; set; }

        [Column(CanBeNull = true)]
        public string Name { get; set; }
    }
}
