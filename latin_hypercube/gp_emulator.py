def emulate(response_file, samples_file):

    print("Processing {}".format(response_file))

    # Load Samples file as Pandas DataFrame
    samples = pd.read_csv(samples_file, delimiter=",", squeeze=True, skipinitialspace=True)

    # Load Respone file as Pandas DataFrame
    response = pd.read_csv(response_file, delimiter=",", squeeze=True, skipinitialspace=True)
    # It is possible that not all ensemble simulations succeeded and returned a value
    # so we much search for missing response values
    missing_ids = list(set(samples["id"]).difference(response["id"]))
    Y = response[response.columns[-1]].values.reshape(1, -1).T
    if missing_ids:
        print("The following simulation ids are missing:\n   {}".format(missing_ids))
        # and remove the missing samples
        samples_missing_removed = samples[~samples["id"].isin(missing_ids)]
        X = samples_missing_removed.values[:, 1::]

    else:
        X = samples.values[:, 1::]

    # Dimension n of kernel
    n = X.shape[1]

    # We choose a kernel
    k = gp.kern.Exponential(input_dim=n, ARD=True)

    m = gp.models.GPRegression(X, Y, k)
    m.optimize(messages=True)

    X_new = draw_samples(10000)

    p = m.predict(X_new.values)

    pctls_gp = np.percentile(p[0], m_percentiles)
    pctls = np.percentile(Y, m_percentiles)
    pctls_df = pd.DataFrame(data=np.vstack([pctls, pctls_gp]).T, index=[5, 16, 50, 84, 95], columns=["lhs", "gp"])

    return response_file, pctls_df
