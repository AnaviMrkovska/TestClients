using Clients.DataAccess.Repository.IRepository;
using Clients.Models;
using Dapper;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace Clients.DataAccess.Repository
{
    public class ClientsRepository : IClientsRepository
    {
        private readonly string _connStr;
        public ClientsRepository(string connStr)
        {
            _connStr = connStr;
        }

        public async Task<IQueryable<Models.Clients>> GetAllClientsFromDatabase()
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {

                await conn.OpenAsync();
                try
                {
                    var res = await conn.QueryAsync<Models.Clients>(
                        "[dbo].[p_ClientsGet]",
                        commandType: System.Data.CommandType.StoredProcedure
                        );
                    await conn.CloseAsync();
                    return res.AsQueryable();
                }
                catch
                {
                    await conn.CloseAsync();
                    return null;
                }
            }
        }      

        public async Task<string> InsertClientsFromXml(ClientsImport file)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                await conn.OpenAsync();
                try
                {
                    var param = new DynamicParameters();
                    param.Add("@p_xmlInput", file.xml);
                   

                    var res = await conn.QueryFirstAsync<string>
                        ("[dbo].[p_ClientsInsertFromXML]", param, commandType: System.Data.CommandType.StoredProcedure);

                    await conn.CloseAsync();
                    return res;

                }
                catch (Exception ex)
                {
                    await conn.CloseAsync();
                    return null;

                }
            }
        }
        public async Task<string> InsertClient(Models.Clients client)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                await conn.OpenAsync();
                try
                {
                    var param = new DynamicParameters();
                    param.Add("@p_ClientNumber", client.ID);
                    param.Add("@p_Name",client.Name);
                    param.Add("@p_BirthDay", client.BirthDate);
                    param.Add("@p_AdressData", client.AdressData);

                    var res = await conn.QueryFirstAsync<string>
                        ("dbo.InsertClient", param, commandType: System.Data.CommandType.StoredProcedure);

                    await conn.CloseAsync();
                    return res;

                }
                catch (Exception ex)
                {
                    await conn.CloseAsync();
                    return "";

                }
            }
        }
    }
}
