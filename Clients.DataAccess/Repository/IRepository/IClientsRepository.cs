using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using Clients.Models;

namespace Clients.DataAccess.Repository.IRepository
{
    public interface IClientsRepository
    {
        public Task<IQueryable<Clients.Models.Clients>> GetAllClientsFromDatabase();
        public Task<string> InsertClientsFromXml(ClientsImport xml );
        public Task<string> InsertClient(Clients.Models.Clients client);
    }
}
